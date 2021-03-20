from django.urls import path

from tasks.views import DeleteTaskView, EditTaskView, NewTaskView, TaskListView

app_name = "tasks"

urlpatterns = [
    path("new", NewTaskView.as_view(), name="new"),
    path("<uuid:pk>/edit", EditTaskView.as_view(), name="edit"),
    path("<uuid:pk>/delete", DeleteTaskView.as_view(), name="delete"),
    path("", TaskListView.as_view(), name="index"),
]
