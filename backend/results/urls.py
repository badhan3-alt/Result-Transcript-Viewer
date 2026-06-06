from django.urls import path
from .views import ResultListCreateView, ResultDetailView, StudentResultView

urlpatterns = [
    path('', ResultListCreateView.as_view()),
    path('<int:pk>/', ResultDetailView.as_view()),
    path('student/<str:student_id>/', StudentResultView.as_view()),
]