from django.urls import path

from blog.views import (
    DeletePostView,
    DetailPostView,
    EditPostView,
    ListPostView,
    NewPostView,
)

app_name = "blog"

urlpatterns = [
    path("", ListPostView.as_view(), name="index"),
    path("new", NewPostView.as_view(), name="new"),
    path("<uuid:pk>/", DetailPostView.as_view(), name="detail"),
    path("<uuid:pk>/edit", EditPostView.as_view(), name="edit"),
    path("<uuid:pk>/delete", DeletePostView.as_view(), name="delete"),
]
