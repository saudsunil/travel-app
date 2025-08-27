from rest_framework.views import APIView
from rest_framework.generics import RetrieveAPIView
from rest_framework.response import Response
from rest_framework import status
from firebase_admin import auth, credentials, initialize_app
from api.models import User
import firebase_admin
from django.contrib.auth.hashers import check_password
from django.contrib.auth import get_user_model, authenticate
from django.http import JsonResponse
import json
from firebase_admin import auth as firebase_auth
from django.db.models import Q

from .models import TravelPlace, UserSubmittedPlace, UserSubmittedPlaceImage, UserProfile, Notification
from .serializers import TravelPlaceSerializer, UserSubmittedPlaceSerializer, UserSubmittedPlaceImageSerializer, UserProfileSerializer, SearchUserProfileSerializer, NotificationSerializer
from rest_framework import generics, permissions, status
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.permissions import AllowAny
from firebase_admin import auth as firebase_auth
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.decorators import api_view, permission_classes
from django.utils.text import slugify
from api.authentication import JWTOrFirebaseAuthentication
from django.utils import timezone
import logging








# Initialize Firebase Admin SDK
if not firebase_admin._apps:
    cred = credentials.Certificate("firebase_credential.json")  # Make sure this path is correct
    firebase_admin.initialize_app(cred)

User = get_user_model()

class FirebaseSignupView(APIView):
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        try:
            data = json.loads(request.body)
            id_token = data.get("id_token")
            password = data.get("password")
            username = data.get("username")

            if not id_token:
                return Response({"error": "Missing Firebase ID token"}, status=status.HTTP_400_BAD_REQUEST)

            # Verify Firebase token
            decoded_token = firebase_auth.verify_id_token(id_token)
            firebase_uid = decoded_token.get("uid")
            email = decoded_token.get("email")

            if not firebase_uid or not email:
                return Response({"error": "Invalid Firebase token (no uid/email)"}, status=status.HTTP_400_BAD_REQUEST)

            # Check if user with email already exists
            existing_user = User.objects.filter(email=email).first()
            if existing_user:
                return Response({"error": "An account with this email already exists. Please log in instead."},
                                status=status.HTTP_409_CONFLICT)

            # Generate unique username if not provided
            if not username:
                base_username = slugify(email.split('@')[0])
            else:
                base_username = slugify(username)

            unique_username = base_username
            counter = 1
            while User.objects.filter(username=unique_username).exists():
                unique_username = f"{base_username}{counter}"
                counter += 1

            # Create new user
            user = User(
                email=email,
                username=unique_username,
                firebase_uid=firebase_uid,
            )

            if password:
                user.set_password(password)
            else:
                user.set_unusable_password()

            user.save()

            # Generate JWT token
            refresh = RefreshToken.for_user(user)
            access_token = str(refresh.access_token)

            return Response({
                "message": "User created successfully",
                "token": access_token,
                "user": {
                    "id": user.id,
                    "email": user.email,
                    "username": user.username
                }
            }, status=status.HTTP_201_CREATED)

        except firebase_auth.InvalidIdTokenError:
            return Response({"error": "Invalid Firebase ID token"}, status=status.HTTP_401_UNAUTHORIZED)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
 
logger = logging.getLogger(__name__)

class ManualLoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        identifier = request.data.get('identifier')
        password = request.data.get('password')

        if not identifier or not password:
            logger.warning("ManualLoginView: Missing identifier or password")
            return Response({'error': 'Both identifier and password are required'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.get(Q(email__iexact=identifier) | Q(username__iexact=identifier))
        except User.DoesNotExist:
            logger.warning(f"ManualLoginView: User not found for identifier '{identifier}'")
            return Response({'error': 'Invalid email or username'}, status=status.HTTP_401_UNAUTHORIZED)

        if not user.check_password(password):
            logger.warning(f"ManualLoginView: Incorrect password attempt for user '{identifier}'")
            return Response({'error': 'Incorrect password'}, status=status.HTTP_401_UNAUTHORIZED)

        try:
            refresh = RefreshToken.for_user(user)
            access_token = str(refresh.access_token)
        except Exception as e:
            logger.error(f"ManualLoginView: Token generation failed for user '{user.id}': {str(e)}")
            return Response({'error': 'Failed to generate authentication token'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        logger.info(f"ManualLoginView: Successful login for user '{user.username}'")
        return Response({
            "message": "Login successful",
            "token": access_token,
            "user": {
                "id": user.id,
                "email": user.email,
                "username": user.username
            }
        }, status=status.HTTP_200_OK)


class GoogleLoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        data = request.data
        id_token = data.get("id_token")
        email = data.get("email")
        username = data.get("username") or (email.split('@')[0] if email else None)

        if not id_token or not email:
            logger.warning("GoogleLoginView: Missing id_token or email in request")
            return Response({"error": "ID token and email are required"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            decoded_token = firebase_auth.verify_id_token(id_token)
            firebase_uid = decoded_token.get("uid")
            if not firebase_uid:
                logger.warning("GoogleLoginView: Firebase token missing UID")
                return Response({"error": "Invalid Firebase token"}, status=status.HTTP_401_UNAUTHORIZED)
        except Exception as e:
            logger.warning(f"GoogleLoginView: Firebase token verification failed: {str(e)}")
            return Response({"error": "Invalid token"}, status=status.HTTP_401_UNAUTHORIZED)

        # Try to find user by email first, fallback to firebase_uid
        user = User.objects.filter(email=email).first()
        if not user:
            user = User.objects.filter(firebase_uid=firebase_uid).first()

        if not user:
            # Create new user
            user = User(firebase_uid=firebase_uid, email=email, username=username)
            user.set_unusable_password()
            user.save()
            logger.info(f"GoogleLoginView: Created new user with email '{email}' and firebase_uid '{firebase_uid}'")
        else:
            # Update firebase_uid if missing
            if not user.firebase_uid:
                user.firebase_uid = firebase_uid
                user.save()
                logger.info(f"GoogleLoginView: Updated firebase_uid for user '{user.username}'")

        try:
            refresh = RefreshToken.for_user(user)
            access_token = str(refresh.access_token)
        except Exception as e:
            logger.error(f"GoogleLoginView: Token generation failed for user '{user.id}': {str(e)}")
            return Response({"error": "Failed to generate authentication token"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        logger.info(f"GoogleLoginView: Successful login for user '{user.username}'")
        return Response({
            "message": "Google login successful",
            "token": access_token,
            "user": {
                "id": user.id,
                "email": user.email,
                "username": user.username
            }
        }, status=status.HTTP_200_OK)
   
class TravelPlaceListView(APIView):
    permission_classes = [AllowAny] 
    
    def get(self, request):
        places = TravelPlace.objects.all().order_by('-created_at')
        serializer = TravelPlaceSerializer(places, many=True, context={'request': request})
        return Response(serializer.data)
    
    


class TravelPlaceDetail(APIView):
    permission_classes = [AllowAny]

    def get(self, request, pk):
        source = request.query_params.get('source', 'admin')  # default admin

        if source == 'admin':
            try:
                place = TravelPlace.objects.get(pk=pk)
                serializer = TravelPlaceSerializer(place, context={'request': request})
            except TravelPlace.DoesNotExist:
                return Response({'error': 'Place not found'}, status=status.HTTP_404_NOT_FOUND)
        elif source == 'user':
            try:
                place = UserSubmittedPlace.objects.get(pk=pk, is_approved=True)
                serializer = UserSubmittedPlaceSerializer(place, context={'request': request})
            except UserSubmittedPlace.DoesNotExist:
                return Response({'error': 'User submitted place not found'}, status=status.HTTP_404_NOT_FOUND)
        else:
            return Response({'error': 'Invalid source parameter'}, status=status.HTTP_400_BAD_REQUEST)

        return Response(serializer.data)

    
class PopularTravelPlaceListView(APIView):
    permission_classes = [AllowAny]
    
    def get(self, request):
        popular_places = TravelPlace.objects.filter(is_popular=True).order_by('-created_at')
        serializer = TravelPlaceSerializer(popular_places, many=True, context={'request': request})
        return Response(serializer.data)
    
    

class SubmitUserPlaceView(generics.CreateAPIView):
    queryset = UserSubmittedPlace.objects.all()
    serializer_class = UserSubmittedPlaceSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]
    
    
  
    def create(self, request, *args, **kwargs):
        name = request.data.get('name', '').strip()


        # 🔍 Check if already approved user place exists
        duplicate_in_user = UserSubmittedPlace.objects.filter(
            name__iexact=name,

            is_approved=True
        ).exists()

        # 🔍 Check if already admin place exists
        duplicate_in_admin = TravelPlace.objects.filter(
            name__iexact=name,
           
        ).exists()

        if duplicate_in_user or duplicate_in_admin:
            return Response(
                {'error': 'This place already exists in the database.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=request.user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        else:
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class UploadUserPlaceImageView(generics.CreateAPIView):
    serializer_class = UserSubmittedPlaceImageSerializer
    parser_classes = [MultiPartParser, FormParser]
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, *args, **kwargs):
        place_id = request.data.get('place')
        if not place_id:
            return Response({'error': 'place ID is required'}, status=400)

        try:
            place = UserSubmittedPlace.objects.get(id=place_id, user=request.user)
        except UserSubmittedPlace.DoesNotExist:
            return Response({'error': 'Place not found or not owned by you'}, status=404)

        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            serializer.save(place=place)
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)


class ApprovedUserPlacesList(generics.ListAPIView):
    queryset = UserSubmittedPlace.objects.filter(is_approved=True)
    serializer_class = UserSubmittedPlaceSerializer

class CombinedTravelPlacesView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        # Get admin travel places
        admin_places = TravelPlace.objects.all().order_by('-created_at')
        admin_serialized = TravelPlaceSerializer(admin_places, many=True, context={'request': request}).data
        for item in admin_serialized:
            item['source'] = 'admin'  # Tagging source (optional)

        # Get approved user-submitted places
        user_places = UserSubmittedPlace.objects.filter(is_approved=True).order_by('-submitted_at')
        user_serialized = UserSubmittedPlaceSerializer(user_places, many=True, context={'request': request}).data
        for item in user_serialized:
            item['source'] = 'user'

        combined = admin_serialized + user_serialized
        return Response(combined, status=200)



User = get_user_model()

class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def get(self, request):
        user = request.user
        profile, _ = UserProfile.objects.get_or_create(user=user)
        serializer = UserProfileSerializer(profile, context={'request': request})

        return Response({
            "username": user.username,
            "email": user.email,
            "profile": serializer.data,
            "posts": []  # Optional: include posts here if needed
        })

    def put(self, request):
        user = request.user
        profile, _ = UserProfile.objects.get_or_create(user=user)

        # ✅ Update User fields
        if 'username' in request.data:
            user.username = request.data['username']
        if 'email' in request.data:
            user.email = request.data['email']
        user.save()

        # ✅ Update Profile fields
        serializer = UserProfileSerializer(
            profile,
            data=request.data,
            partial=True,
            context={'request': request}
        )

        if serializer.is_valid():
            serializer.save()
            return Response({
                "username": user.username,
                "email": user.email,
                "profile": serializer.data
            })
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def search_users(request):
    print("🔐 Authenticated user:", request.user)
    query = request.GET.get('q', '').strip()
    if not query:
        return Response([ ], status=200)

    results = UserProfile.objects.filter(
        Q(user__username__icontains=query) | Q(full_name__icontains=query)
    ).exclude(user=request.user)  # exclude self

    serializer = SearchUserProfileSerializer(results, many=True, context={'request': request})
    return Response(serializer.data)



@api_view(['POST'])
@permission_classes([IsAuthenticated])
def toggle_follow_user(request, user_id):
    try:
        target_profile = UserProfile.objects.get(user__id=user_id)
        current_profile = request.user.profile

        if current_profile == target_profile:
            return Response({'error': 'You cannot follow yourself'}, status=400)

        if target_profile.followers.filter(id=current_profile.id).exists():
            # 🔁 Unfollow
            target_profile.followers.remove(current_profile)
            current_profile.following.remove(target_profile)

            # 🔁 Deactivate follow notification if exists
            Notification.objects.filter(
                sender=request.user,
                receiver=target_profile.user,
                notification_type='follow'
            ).update(is_active=False)

            return Response({'status': f'Unfollowed {target_profile.user.username}'}, status=200)

        else:
    # ✅ Follow
         target_profile.followers.add(current_profile)
         current_profile.following.add(target_profile)

    # ✅ Notify followed user
        Notification.objects.update_or_create(
        sender=request.user,
        receiver=target_profile.user,
        notification_type='follow',
        defaults={
            'message': f"{request.user.username} started following you.",
            'is_active': True,
            'is_read': False,
            'timestamp': timezone.now()
        }
    )

    # ✅ Check if followed user had already followed current user — then notify them about follow back
        if current_profile in target_profile.following.all():
           Notification.objects.update_or_create(
             sender=request.user,
            receiver=target_profile.user,
            notification_type='follow_back',
            defaults={
                'message': f"{request.user.username} followed you back.",
                'is_active': True,
                'is_read': False,
                'timestamp': timezone.now()
            }
        )

        return Response({'status': f'Followed {target_profile.user.username}'}, status=201)


    except UserProfile.DoesNotExist:
        return Response({'error': 'User not found'}, status=404)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def unfollow_user(request, user_id):
    try:
        target = UserProfile.objects.get(user__id=user_id)
        current = request.user.profile

        if current == target:
            return Response({'error': 'You cannot unfollow yourself'}, status=400)

        target.followers.remove(current)
        return Response({'status': f'You unfollowed {target.user.username}'})
    except UserProfile.DoesNotExist:
        return Response({'error': 'User not found'}, status=404)



class ViewOtherUserProfile(APIView):
    authentication_classes = [JWTOrFirebaseAuthentication]
    permission_classes = [IsAuthenticated]

    def get(self, request, user_id):
        try:
            profile = UserProfile.objects.get(user__id=user_id)
            serializer = SearchUserProfileSerializer(profile, context={'request': request})
            return Response(serializer.data)
        except UserProfile.DoesNotExist:
            return Response({'error': 'User not found'}, status=404)
        
 
class UserNotificationsView(generics.ListAPIView):
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    
    def get_queryset(self):
        return Notification.objects.filter(
            receiver=self.request.user
        ).order_by('-timestamp')  # ✅ Removed type filtering

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        serializer = self.get_serializer(queryset, many=True, context={'request': request})
        return Response(serializer.data)


class MarkAllNotificationsReadView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        Notification.objects.filter(receiver=request.user, is_read=False).update(is_read=True)
        return Response(status=status.HTTP_204_NO_CONTENT)
    

User = get_user_model()



# @api_view(['GET'])
# @permission_classes([IsAuthenticated])
# def get_followed_users(request):
#     profile = request.user.profile
#     followed_profiles = profile.following.all()

#     result = []
#     for p in followed_profiles:
#         profile_image = (
#             request.build_absolute_uri(p.photo.url)
#             if p.photo else ""
#         )
#         result.append({
#             "id": p.user.id,
#             "username": p.user.username,
#             "profile_image": profile_image,
#         })

#     return Response(result)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_followed_users(request):
    profile = request.user.profile
    followed_profiles = profile.following.all()

    result = []
    for p in followed_profiles:
        profile_image = request.build_absolute_uri(p.photo.url) if p.photo else ""
        result.append({
            "id": p.user.id,
            "username": p.user.username,
            "profile_image": profile_image,
        })

    return Response(result)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_followers(request, user_id):
    try:
        target_profile = UserProfile.objects.get(user__id=user_id)
        followers = target_profile.followers.all()

        result = []
        for p in followers:
            profile_image = request.build_absolute_uri(p.photo.url) if p.photo else ""
            result.append({
                "id": p.user.id,
                "username": p.user.username,
                "profile_image": profile_image,
            })

        return Response(result)
    except UserProfile.DoesNotExist:
        return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)

