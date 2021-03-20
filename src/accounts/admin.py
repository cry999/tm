from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.utils.translation import ugettext_lazy as _

from accounts.models import User

# Register your models here.


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    fieldsets = (
        (None, {"fields": ("username", "password")}),
        (_("Personal info"), {"fields": ("email",)}),
    )
    list_display = ("username", "email", "is_staff")
    search_fields = ("username", "email")
    filter_horizontal = ("groups", "user_permissions")
