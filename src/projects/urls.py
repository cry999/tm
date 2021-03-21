from django.urls.conf import path

from projects.views import (
    DeleteProjectView,
    DetailProjectView,
    EditProjectView,
    ListProjectsView,
    NewProjectView,
)

app_name = "projects"

urlpatterns = [
    path("", ListProjectsView.as_view(), name="index"),
    path("new/", NewProjectView.as_view(), name="new"),
    path("<uuid:pk>/", DetailProjectView.as_view(), name="detail"),
    path("<uuid:pk>/edit", EditProjectView.as_view(), name="edit"),
    path("<uuid:pk>/delete", DeleteProjectView.as_view(), name="delete"),
]
