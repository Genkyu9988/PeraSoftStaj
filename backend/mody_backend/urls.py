from django.urls import path
from mody_api import views

urlpatterns = [
    path('api/v1/health', views.health),
    path('api/v1/catalog', views.catalog),
    path('api/v1/creations', views.creations),
    path('api/v1/selections', views.selections),
    path('api/v1/ai/change-color', views.generate_color),
    path('api/v1/ai/spoiler', views.generate_spoiler),
    path('api/v1/ai/media', views.ai_media),
]
