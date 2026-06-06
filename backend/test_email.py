import os
import django
from django.conf import settings
from django.core.mail import send_mail

# Configure settings manually for a quick script test
if not settings.configured:
    settings.configure(
        EMAIL_BACKEND='django.core.mail.backends.smtp.EmailBackend',
        EMAIL_HOST='smtp.gmail.com',
        EMAIL_PORT=587,
        EMAIL_USE_TLS=True,
        EMAIL_HOST_USER='badhandas715@gmail.com',
        EMAIL_HOST_PASSWORD='dnqz cmus hkty tape',
        DEFAULT_FROM_EMAIL='badhandas715@gmail.com'
    )

try:
    print("Attempting to send test email...")
    send_mail(
        'Academic Ledger - Test OTP',
        'Your test OTP is: 999999',
        'badhandas715@gmail.com',
        ['badhandas715@gmail.com'],
        fail_silently=False,
    )
    print("SUCCESS: Test email sent successfully to badhandas715@gmail.com!")
except Exception as e:
    print(f"FAILED: Could not send email. Error: {e}")
