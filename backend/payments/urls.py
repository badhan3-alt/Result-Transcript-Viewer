from django.urls import path
from .views import StudentTransactionListView, TransactionCreateView, SendPaymentOTPView

urlpatterns = [
    path('student-transactions/', StudentTransactionListView.as_view(), name='student-transactions'),
    path('submit/', TransactionCreateView.as_view(), name='submit-transaction'),
    path('request-otp/', SendPaymentOTPView.as_view(), name='request-payment-otp'),
]
