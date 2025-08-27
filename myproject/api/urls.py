from django.urls import path

from .views import FirebaseSignupView, ManualLoginView, GoogleLoginView,  TravelPlaceListView,  TravelPlaceDetail,  PopularTravelPlaceListView, SubmitUserPlaceView, UploadUserPlaceImageView, ApprovedUserPlacesList, CombinedTravelPlacesView, UserProfileView ,search_users,  toggle_follow_user, unfollow_user, ViewOtherUserProfile, UserNotificationsView, MarkAllNotificationsReadView,get_followed_users, get_followers




urlpatterns = [
    
    
    path('auth/firebase-signup/', FirebaseSignupView.as_view(), name='firebase-signup'),
    path('auth/manual-login/', ManualLoginView.as_view(), name='manual-login'),
    path('auth/google-login/', GoogleLoginView.as_view(), name='google-login'),
    path('travel-places/', TravelPlaceListView.as_view(), name='travel-place-list'),
    path('travel-places/<int:pk>/', TravelPlaceDetail.as_view(), name='travelplace-detail'),
    path('popular-travel-places/', PopularTravelPlaceListView.as_view(), name='popular-travel-places'),
    path('user-places/submit/', SubmitUserPlaceView.as_view(), name='submit-user-place'),
    path('user-places/upload-image/', UploadUserPlaceImageView.as_view(), name='upload-user-place-image'),
    path('user-places/approved/', ApprovedUserPlacesList.as_view(), name='approved-user-places'),
    path('all-travel-places/', CombinedTravelPlacesView.as_view(), name='all-travel-places'),
    path('profile/', UserProfileView.as_view(), name='user-profile'),
        # ✅ NEW search & follow URLs
    path('search/', search_users, name='user-search'),
  
    path("profile/<int:user_id>/", ViewOtherUserProfile.as_view(), name="view_user_profile"),

    path('follow/<int:user_id>/', toggle_follow_user, name='user-follow'),
    path('unfollow/<int:user_id>/', unfollow_user, name='user-unfollow'),
    path('notifications/', UserNotificationsView.as_view(), name='notifications'),
    path('notifications/mark-all-read/', MarkAllNotificationsReadView.as_view()),
    path('following/', get_followed_users, name='get-followed-users'),
    path('followers/<int:user_id>/', get_followers),


]
