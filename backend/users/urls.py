from django.urls import path
from .views import LoginView, RegisterView, StudentListView, UpdateStudentStatusView, VerifyOTPView, ForgotPasswordView, ResetPasswordView

urlpatterns = [
    path('login/', LoginView.as_view()),
    path('register/', RegisterView.as_view()),
    path('verify-otp/', VerifyOTPView.as_view()),
    path('students/', StudentListView.as_view()),
    path('students/<int:pk>/update/', UpdateStudentStatusView.as_view()),
    path('forgot-password/', ForgotPasswordView.as_view()),
    path('reset-password/', ResetPasswordView.as_view()),
]