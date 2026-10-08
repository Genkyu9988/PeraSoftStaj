import 'dart:async';
import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perasoft_staj/product/cache/creation_repository.dart';
import 'package:perasoft_staj/product/model/creation_record.dart';
import 'package:perasoft_staj/product/model/generation_result.dart';

final class CreationHistoryState extends Equatable {
  CreationHistoryState({
    List<CreationRecord> records = const [],
    this.loading = false,
    this.loadFailed = false,
    this.saveFailed = false,
    this.saving = false,
  }) : records = List.unmodifiable(records);
  final List<CreationRecord> records;
  final bool loading;
  final bool loadFailed;
  final bool saveFailed;
  final bool saving;
  List<CreationRecord> get images =>
      records.where((r) => !r.isVideoDemo).toList();
  List<CreationRecord> get videos =>
      records.where((r) => r.isVideoDemo).toList();

  CreationHistoryState copyWith({
    List<CreationRecord>? records,
    bool? loading,
    bool? loadFailed,
    bool? saveFailed,
    bool? saving,
  }) => CreationHistoryState(
    records: records ?? this.records,
    loading: loading ?? this.loading,
    loadFailed: loadFailed ?? this.loadFailed,
    saveFailed: saveFailed ?? this.saveFailed,
    saving: saving ?? this.saving,
  );
  @override
  List<Object> get props => [records, loading, loadFailed, saveFailed, saving];
}

/// One shared history for every route. UI navigation never creates records.
final class CreationHistoryCubit extends Cubit<CreationHistoryState> {
  CreationHistoryCubit({
    required CreationRepository repository,
    DateTime Function()? clock,
  }) : _repository = repository,
       _clock = clock ?? DateTime.now,
       super(CreationHistoryState());
  final CreationRepository _repository;
  final DateTime Function() _clock;
  final String _session =
      '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';
  int _revision = 0;
  bool _canSave = false;
  Future<void>? _loading;
  Future<void> _pendingSave = Future.value();
  Future<void> get pendingSave => _pendingSave;

  Future<void> load() =>
      _loading ??= _load().whenComplete(() => _loading = null);

  Future<void> _load() async {
    if (isClosed) return;
    emit(state.copyWith(loading: true));
    try {
      final stored = await _repository.load();
      if (isClosed) return;
      final merged = {
        for (final r in stored) r.id: r,
        for (final r in state.records) r.id: r,
      };
      final records = merged.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _canSave = true;
      emit(state.copyWith(records: records, loading: false, loadFailed: false));
      if (_revision > 0) _save();
    } catch (_) {
      if (!isClosed) {
        _canSave = false;
        // Never overwrite an unreadable/unknown-version history with an empty list.
        emit(state.copyWith(loading: false, loadFailed: true));
      }
    }
  }

  void record(GenerationResult result) {
    if (isClosed) return;
    final demo = switch (result) {
      DemoGenerationResult r => r,
    };
    final record = CreationRecord(
      id: '$_session-${++_revision}',
      createdAt: _clock().toUtc(),
      result: demo,
    );
    emit(state.copyWith(records: [record, ...state.records]));
    if (_canSave) _save();
  }

  Future<void> retryPersistence() async {
    if (isClosed || state.loading || state.saving) return;
    if (!_canSave) {
      await load();
    } else {
      _save();
    }
    await _pendingSave;
  }

  void _save() {
    final snapshot = state.records;
    final revision = _revision;
    emit(state.copyWith(saving: true));
    _pendingSave = _pendingSave.then((_) async {
      var failed = false;
      try {
        await _repository.save(snapshot);
      } catch (_) {
        failed = true;
      }
      if (!isClosed && revision == _revision) {
        emit(state.copyWith(saving: false, saveFailed: failed));
      }
    });
  }
}
