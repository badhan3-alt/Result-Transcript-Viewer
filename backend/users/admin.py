from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import Student, OTPVerification, PendingRegistration

class StudentAdmin(UserAdmin):
    model = Student
    # Fields to display in the list view
    list_display = ("email", "username", "student_id", "department", "current_semester", "is_staff")
    
    # Fields to include in the user detail/edit page
    fieldsets = UserAdmin.fieldsets + (
        ("Academic Information", {"fields": ("student_id", "department", "batch", "current_semester", "academic_year", "faculty_adviser", "enrollment_status")}),
    )
    
    # Fields to include when creating a new user
    add_fieldsets = UserAdmin.add_fieldsets + (
        ("Academic Information", {"fields": ("student_id", "department", "batch", "current_semester", "academic_year", "faculty_adviser", "enrollment_status")}),
    )

admin.site.register(Student, StudentAdmin)
admin.site.register(OTPVerification)
admin.site.register(PendingRegistration)
