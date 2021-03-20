from django.urls import path

from .views import SignInFormView, SignUpFormView, index, signout

app_name = "accounts"

urlpatterns = [
    path("", index, name="index"),
    path("signup", SignUpFormView.as_view(), name="signup"),
    path("signin", SignInFormView.as_view(), name="signin"),
    path("signout", signout, name="signout"),
]
