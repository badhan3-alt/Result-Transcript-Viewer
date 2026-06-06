from django.contrib import admin
from .models import Transaction

# Register your models here.

@admin.register(Transaction)
class TransactionAdmin(admin.ModelAdmin):
    list_display = ('student', 'title', 'amount', 'status', 'created_at')
    list_filter = ('status', 'method')
