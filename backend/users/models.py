from django.db import models

# Create your models here.
from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils import timezone
import datetime

class OTPVerification(models.Model):
    email = models.EmailField(unique=True)
    otp = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)
    
    def is_valid(self):
        return timezone.now() < self.created_at + datetime.timedelta(minutes=10)
        
    def __str__(self):
        return f"{self.email} - {self.otp}"

class PendingRegistration(models.Model):
    email = models.EmailField(unique=True)
    username = models.CharField(max_length=150)
    password = models.CharField(max_length=128)
    student_id = models.CharField(max_length=20, null=True, blank=True)
    department = models.CharField(max_length=100)
    batch = models.CharField(max_length=20, null=True, blank=True)
    user_type = models.CharField(max_length=10)
    otp = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)

    def is_valid(self):
        return timezone.now() < self.created_at + datetime.timedelta(minutes=10)

class Student(AbstractUser):
    USER_TYPES = [
        ('student', 'Student'),
        ('teacher', 'Teacher'),
    ]
    user_type = models.CharField(max_length=10, choices=USER_TYPES, default='student')
    
    email = models.EmailField(unique=True)
    student_id = models.CharField(max_length=20, unique=True, null=True, blank=True)

    DEPARTMENT_CHOICES = [
        ('CSE', 'Computer Science & Engineering'),
        ('LAW', 'Law'),
        ('Eng', 'English'),
        ('BBA', 'Business Administration'),
    ]
    department = models.CharField(max_length=100, choices=DEPARTMENT_CHOICES)
    BATCH_CHOICES = [(str(i), f"Batch {i}") for i in range(1, 9)]
    batch = models.CharField(max_length=20, choices=BATCH_CHOICES, null=True, blank=True)
    
    current_semester = models.IntegerField(default=1, null=True, blank=True)
    academic_year = models.CharField(max_length=20, default="2023-2024")
    faculty_adviser = models.CharField(max_length=200, default="N/A")
    enrollment_status = models.CharField(max_length=50, default="Regular")

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["username", "student_id"]

    def __str__(self):
        return self.email