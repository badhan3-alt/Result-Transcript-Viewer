from django.urls import path
from .views import CourseListCreateView, CourseDetailView, OfferedCourseListView

urlpatterns = [
    path('', CourseListCreateView.as_view()),
    path('<int:pk>/', CourseDetailView.as_view()),
    path('offered/', OfferedCourseListView.as_view()),
]