from django.contrib.auth.mixins import LoginRequiredMixin
from django.db.models.query import QuerySet
from django.http.response import HttpResponse, HttpResponseRedirect
from django.urls import reverse, reverse_lazy
from django.views.generic import CreateView, ListView
from django.views.generic.detail import DetailView
from django.views.generic.edit import DeleteView, UpdateView

from projects.forms import EditProjectForm, NewProjectForm
from projects.models import Project

# Create your views here.


class NewProjectView(CreateView, LoginRequiredMixin):
    template_name = "projects/new.html"
    model = Project
    form_class = NewProjectForm

    def form_valid(self, form: NewProjectForm) -> HttpResponse:
        project: Project = form.save(commit=False)
        project.owner = self.request.user
        project.save()
        return HttpResponseRedirect(
            reverse("projects:detail", kwargs={"pk": project.pk}),
        )


class ListProjectsView(ListView, LoginRequiredMixin):
    template_name = "projects/index.html"
    model = Project
    context_object_name = "projects"

    def get_queryset(self) -> QuerySet:
        return self.model.objects.filter(owner=self.request.user).all()


class DetailProjectView(DetailView, LoginRequiredMixin):
    template_name = "projects/detail.html"
    model = Project
    context_object_name = "project"


class EditProjectView(UpdateView, LoginRequiredMixin):
    template_name = "projects/edit.html"
    model = Project
    form_class = EditProjectForm
    context_object_name = "project"

    def get_success_url(self) -> str:
        return reverse_lazy("projects:detail", kwargs={"pk": self.object.pk})


class DeleteProjectView(DeleteView, LoginRequiredMixin):
    template_name = "projects/confirm_delete.html"
    model = Project
    context_object_name = "project"
    success_url = reverse_lazy("projects:index")
