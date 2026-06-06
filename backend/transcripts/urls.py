from django.urls import path
from .views import TranscriptView

urlpatterns = [
    path('<int:student_id>/', TranscriptView.as_view()),
]