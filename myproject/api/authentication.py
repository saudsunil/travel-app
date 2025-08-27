# from django.contrib.auth.backends import ModelBackend
# from django.contrib.auth import get_user_model
# from django.db.models import Q
# from rest_framework.exceptions import AuthenticationFailed
# from rest_framework.authentication import BaseAuthentication
# from firebase_admin import auth as firebase_auth
# from api.models import User



# UserModel = get_user_model()

# class EmailOrUsernameModelBackend(ModelBackend):
#     def authenticate(self, request, username=None, password=None, **kwargs):
#         try:
#             user = UserModel.objects.get(
#                 Q(email=username) | Q(username=username)
#             )
#         except UserModel.DoesNotExist:
#             return None

#         if user.check_password(password):
#             return user
#         return None


# class FirebaseAuthentication(BaseAuthentication):
#     def authenticate(self, request):
#         auth_header = request.headers.get('Authorization')

#         if not auth_header or not auth_header.startswith('Bearer '):
#             return None

#         id_token = auth_header.split('Bearer ')[1]
#         try:
#             decoded_token = firebase_auth.verify_id_token(id_token)
#             uid = decoded_token.get('uid')

#             user = User.objects.filter(firebase_uid=uid).first()
#             if not user:
#                 raise AuthenticationFailed('User not found')

#             return (user, None)
#         except Exception as e:
#             raise AuthenticationFailed(f'Invalid token: {str(e)}')


from django.contrib.auth.backends import ModelBackend
from django.contrib.auth import get_user_model
from django.db.models import Q
from rest_framework.exceptions import AuthenticationFailed
from rest_framework.authentication import BaseAuthentication
from firebase_admin import auth as firebase_auth
from api.models import User 
import jwt
from rest_framework_simplejwt.authentication import JWTAuthentication

UserModel = get_user_model()


class EmailOrUsernameModelBackend(ModelBackend):
    def authenticate(self, request, username=None, password=None, **kwargs):
        try:
            user = UserModel.objects.get(
                Q(email__iexact=username) | Q(username__iexact=username)
            )
        except UserModel.DoesNotExist:
            return None

        if user.check_password(password):
            return user
        return None



UserModel = get_user_model()

class JWTOrFirebaseAuthentication(BaseAuthentication):
    def authenticate(self, request):
        auth_header = request.headers.get('Authorization', '')
        if not auth_header.startswith('Bearer '):
            return None  # No token, DRF will continue to next auth or deny access

        raw_token = auth_header[len('Bearer '):].strip()

        # 1. Try JWT authentication first
        try:
            jwt_auth = JWTAuthentication()
            validated_token = jwt_auth.get_validated_token(raw_token)
            user = jwt_auth.get_user(validated_token)
            return (user, validated_token)
        except Exception:
            pass  # Failed JWT, fallback to Firebase token verification

        # 2. Try Firebase authentication
        try:
            decoded_token = firebase_auth.verify_id_token(raw_token)
            uid = decoded_token.get('uid')
            if not uid:
                raise AuthenticationFailed("Firebase UID not found in token.")

            user = UserModel.objects.filter(firebase_uid=uid).first()
            if not user:
                raise AuthenticationFailed("User not found for Firebase UID.")

            # DRF expects the second item to be an auth object; None is fine if you don't have one
            return (user, None)

        except Exception as e:
            raise AuthenticationFailed(f"Invalid Firebase token: {str(e)}")
