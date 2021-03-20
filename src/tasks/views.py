from typing import Any, Dict
from django.contrib.auth.mixins import LoginRequiredMixin
from django.db.models.query import QuerySet
from django.db.models.query_utils import Q
from django.http.response import HttpResponse, HttpResponseRedirect
from django.urls import reverse
from django.urls.base import reverse_lazy
from django.views.generic import FormView, ListView
from django.views.generic.edit import DeleteView, UpdateView

from tasks.forms import EditTaskForm, NewTaskForm
from tasks.models import Status, Task

# Create your views here.


class TaskListView(ListView, LoginRequiredMixin):
    model = Task
    context_object_name = "tasks"
    template_name = "tasks/index.html"

    STATUS_FILTER = "status"

    def get_queryset(self) -> QuerySet:
        user = self.request.user
        status = self.request.GET.get(self.STATUS_FILTER, Status.WIP)

        return (
            Task.objects.filter((Q(author=user) | Q(assignee=user)) & Q(status=status))
            .order_by("-priority", "-deadline", "-created_at", "-updated_at")
            .all()
        )

    def get_context_data(self, **kwargs: Any) -> Dict[str, Any]:
        data = super().get_context_data(**kwargs)
        data["statuses"] = Status.values
        return data


class NewTaskView(FormView, LoginRequiredMixin):
    template_name = "tasks/new.html"
    form_class = NewTaskForm

    def form_valid(self, form: NewTaskForm) -> HttpResponse:
        new_task = Task.created_by(
            author=self.request.user,
            name=form.data["name"],
        )
        new_task.save()
        return HttpResponseRedirect(reverse("tasks:index"))


class EditTaskView(UpdateView, LoginRequiredMixin):
    template_name = "tasks/edit.html"
    form_class = EditTaskForm
    success_url = reverse_lazy("tasks:index")

    def get_queryset(self) -> QuerySet:
        user = self.request.user
        assert user.is_authenticated

        return Task.objects.filter(Q(author=user) | Q(assignee=user)).all()


class DeleteTaskView(DeleteView, LoginRequiredMixin):
    template_name = "tasks/confirm_delete.html"
    success_url = reverse_lazy("tasks:index")
    context_object_name = "task"

    def get_queryset(self) -> QuerySet:
        user = self.request.user
        assert user.is_authenticated

        return Task.objects.filter(Q(author=user) | Q(assignee=user)).all()
