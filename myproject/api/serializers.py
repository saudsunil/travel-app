from rest_framework import serializers
from .models import TravelPlace, TravelPlaceImage, UserSubmittedPlace, UserSubmittedPlaceImage
from .models import UserProfile, Post, Notification
from django.contrib.auth import get_user_model


class TravelPlaceImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = TravelPlaceImage
        fields = ['image']


class TravelPlaceSerializer(serializers.ModelSerializer):
    cover_image = serializers.ImageField(use_url=True)
    video = serializers.FileField(use_url=True, required=False)
    images = TravelPlaceImageSerializer(many=True, read_only=True)

    class Meta:
        model = TravelPlace
        fields = '__all__'

class UserSubmittedPlaceImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserSubmittedPlaceImage
        fields = ['id', 'image']

class UserSubmittedPlaceSerializer(serializers.ModelSerializer):
    cover_image = serializers.ImageField(use_url=True)
    video = serializers.FileField(use_url=True, required=False)
    images = UserSubmittedPlaceImageSerializer(many=True, read_only=True)
    user = serializers.ReadOnlyField(source='user.username')  # or use 'user.username' if you want name

    class Meta:
        model = UserSubmittedPlace
        fields = '__all__'
        
        



User = get_user_model()

class PostSerializer(serializers.ModelSerializer):
    class Meta:
        model = Post
        fields = ['id', 'caption', 'media_type', 'media_file', 'created_at']

# class UserProfileSerializer(serializers.ModelSerializer):
#     follower_count = serializers.IntegerField(read_only=True)
#     following_count = serializers.IntegerField(read_only=True)
#     photo = serializers.ImageField(required=False, allow_null=True)
#     photo_url = serializers.SerializerMethodField()

#     class Meta:
#         model = UserProfile
#         fields = [ 'photo','photo_url', 'full_name', 'dob','gender','bio', 'follower_count', 'following_count']
        
#     def get_follower_count(self, obj):
#         return obj.follower_count()

#     def get_following_count(self, obj):
#         return obj.following_count()
        
#     def get_photo_url(self, obj):
        
#         request = self.context.get('request')
#         if obj.photo and hasattr(obj.photo, 'url'):
#             return request.build_absolute_uri(obj.photo.url)
#         return ""

# class UserSerializer(serializers.ModelSerializer):
#     profile = UserProfileSerializer(source='userprofile', read_only=True)
#     posts = PostSerializer(many=True, read_only=True)

#     class Meta:
#         model = User
#         fields = ['id', 'email', 'username', 'profile', 'posts']



class UserProfileSerializer(serializers.ModelSerializer):
    follower_count = serializers.SerializerMethodField()
    following_count = serializers.SerializerMethodField()
    photo_url = serializers.SerializerMethodField()

    class Meta:
        model = UserProfile
        fields = [
            'full_name', 'dob', 'gender', 'photo', 'photo_url',
            'bio', 'follower_count', 'following_count'
        ]
        extra_kwargs = {
            'photo': {'required': False, 'allow_null': True},
            'dob': {'required': False, 'allow_null': True},
            'full_name': {'required': False, 'allow_blank': True},
        }

    def get_follower_count(self, obj):
        return obj.follower_count()

    def get_following_count(self, obj):
        return obj.following_count()

    def get_photo_url(self, obj):
        request = self.context.get('request')
        if obj.photo and hasattr(obj.photo, 'url'):
            return request.build_absolute_uri(obj.photo.url)
        return ""

class UserSerializer(serializers.ModelSerializer):
    profile = UserProfileSerializer(source='profile', read_only=False)
    posts = PostSerializer(many=True, read_only=True)

    class Meta:
        model = User
        fields = ['id', 'email', 'username', 'profile', 'posts']

    def update(self, instance, validated_data):
        profile_data = validated_data.pop('profile', {})
        # Update User fields if any
        instance.email = validated_data.get('email', instance.email)
        instance.username = validated_data.get('username', instance.username)
        instance.save()

        # Update or create profile fields
        profile = instance.profile
        for attr, value in profile_data.items():
            setattr(profile, attr, value)
        profile.save()

        return instance
    


class SearchUserProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username')
    email = serializers.EmailField(source='user.email')
    id = serializers.IntegerField(source='user.id')
    photo_url = serializers.SerializerMethodField()
    is_following = serializers.SerializerMethodField()
    is_follower = serializers.SerializerMethodField()
    follower_count = serializers.SerializerMethodField()
    following_count = serializers.SerializerMethodField()

    class Meta:
        model = UserProfile
        fields = [
            'id', 'username', 'email', 'full_name', 'photo_url',
            'follower_count', 'following_count',
            'is_following', 'is_follower'
        ]

    def get_photo_url(self, obj):
        request = self.context.get('request')
        if obj.photo and hasattr(obj.photo, 'url'):
            return request.build_absolute_uri(obj.photo.url)
        return None

    def get_is_following(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            try:
                return obj in request.user.profile.following.all()
            except:
                return False
        return False

    def get_is_follower(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            try:
                return request.user.profile in obj.following.all()
            except:
                return False
        return False

    def get_follower_count(self, obj):
        return obj.followers.count()

    def get_following_count(self, obj):
        return obj.following.count()



class NotificationSerializer(serializers.ModelSerializer):
    sender_username = serializers.CharField(source='sender.username', read_only=True)
    sender_photo_url = serializers.SerializerMethodField()
    is_following = serializers.SerializerMethodField()
    is_follower = serializers.SerializerMethodField()

    class Meta:
        model = Notification
        fields = [
            'id', 'sender', 'sender_username', 'receiver', 'notification_type',
            'message', 'is_read', 'timestamp', 'is_active',  # ✅ added here
            'sender_photo_url', 'is_following', 'is_follower'
        ]

    def get_sender_photo_url(self, obj):
        request = self.context.get('request')
        if hasattr(obj.sender, 'profile') and obj.sender.profile.photo:
            return request.build_absolute_uri(obj.sender.profile.photo.url)
        return ''

    def get_is_following(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.sender.profile in request.user.profile.following.all()
        return False

    def get_is_follower(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.sender.profile in request.user.profile.followers.all()
        return False
