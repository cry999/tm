from django.contrib import admin

from .models import Task

# Register your models here.


@admin.register(Task)
class AdminTask(admin.ModelAdmin):
    fieldsets = ((None, {"fields": ("summary", "owner")}),)
    list_display = ("summary", "owner", "created_at", "updated_at")
