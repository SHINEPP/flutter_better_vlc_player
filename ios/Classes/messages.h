// Autogenerated from Pigeon (v0.2.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon
#import <Foundation/Foundation.h>
@protocol FlutterBinaryMessenger;
@class FlutterError;
@class FlutterStandardTypedData;

NS_ASSUME_NONNULL_BEGIN

@class CreateMessage;
@class ViewMessage;
@class SetMediaMessage;
@class BooleanMessage;
@class LongMessage;
@class LoopingMessage;
@class PositionMessage;
@class DurationMessage;
@class VolumeMessage;
@class PlaybackSpeedMessage;
@class SnapshotMessage;
@class TrackCountMessage;
@class SpuTracksMessage;
@class SpuTrackMessage;
@class DelayMessage;
@class AddSubtitleMessage;
@class AudioTracksMessage;
@class AudioTrackMessage;
@class AddAudioMessage;
@class VideoTracksMessage;
@class VideoTrackMessage;
@class VideoScaleMessage;
@class VideoAspectRatioMessage;
@class RendererServicesMessage;
@class RendererScanningMessage;
@class RendererDevicesMessage;
@class RenderDeviceMessage;
@class RecordMessage;

@interface CreateMessage : NSObject
@property(nonatomic, copy, nullable) NSString * uri;
@property(nonatomic, strong, nullable) NSNumber * type;
@property(nonatomic, copy, nullable) NSString * packageName;
@property(nonatomic, strong, nullable) NSNumber * autoPlay;
@property(nonatomic, strong, nullable) NSNumber * hwAcc;
@property(nonatomic, strong, nullable) NSArray * options;
@end

@interface ViewMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@end

@interface SetMediaMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, copy, nullable) NSString * uri;
@property(nonatomic, strong, nullable) NSNumber * type;
@property(nonatomic, copy, nullable) NSString * packageName;
@property(nonatomic, strong, nullable) NSNumber * autoPlay;
@property(nonatomic, strong, nullable) NSNumber * hwAcc;
@end

@interface BooleanMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, strong, nullable) NSNumber * result;
@end

@interface LongMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, strong, nullable) NSNumber * result;
@end

@interface LoopingMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, strong, nullable) NSNumber * isLooping;
@end

@interface PositionMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, strong, nullable) NSNumber * position;
@end

@interface DurationMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, strong, nullable) NSNumber * duration;
@end

@interface VolumeMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, strong, nullable) NSNumber * volume;
@end

@interface PlaybackSpeedMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, strong, nullable) NSNumber * speed;
@end

@interface SnapshotMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, copy, nullable) NSString * snapshot;
@end

@interface TrackCountMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, strong, nullable) NSNumber * count;
@end

@interface SpuTracksMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, strong, nullable) NSDictionary * subtitles;
@end

@interface SpuTrackMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, strong, nullable) NSNumber * spuTrackNumber;
@end

@interface DelayMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, strong, nullable) NSNumber * delay;
@end

@interface AddSubtitleMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, copy, nullable) NSString * uri;
@property(nonatomic, strong, nullable) NSNumber * type;
@property(nonatomic, strong, nullable) NSNumber * isSelected;
@end

@interface AudioTracksMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, strong, nullable) NSDictionary * audios;
@end

@interface AudioTrackMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, strong, nullable) NSNumber * audioTrackNumber;
@end

@interface AddAudioMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, copy, nullable) NSString * uri;
@property(nonatomic, strong, nullable) NSNumber * type;
@property(nonatomic, strong, nullable) NSNumber * isSelected;
@end

@interface VideoTracksMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, strong, nullable) NSDictionary * videos;
@end

@interface VideoTrackMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, strong, nullable) NSNumber * videoTrackNumber;
@end

@interface VideoScaleMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, strong, nullable) NSNumber * scale;
@end

@interface VideoAspectRatioMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, copy, nullable) NSString * aspectRatio;
@end

@interface RendererServicesMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, strong, nullable) NSArray * services;
@end

@interface RendererScanningMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, copy, nullable) NSString * rendererService;
@end

@interface RendererDevicesMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, strong, nullable) NSDictionary * rendererDevices;
@end

@interface RenderDeviceMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, copy, nullable) NSString * rendererDevice;
@end

@interface RecordMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * viewId;
@property(nonatomic, copy, nullable) NSString * saveDirectory;
@end

@protocol VlcPlayerApi
-(nullable LongMessage *)create:(CreateMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)dispose:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)setStreamUrl:(SetMediaMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)play:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)pause:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)stop:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable BooleanMessage *)isPlaying:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable BooleanMessage *)isSeekable:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)setLooping:(LoopingMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)seekTo:(PositionMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable PositionMessage *)position:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable DurationMessage *)duration:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)setVolume:(VolumeMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable VolumeMessage *)getVolume:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)setPlaybackSpeed:(PlaybackSpeedMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable PlaybackSpeedMessage *)getPlaybackSpeed:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable SnapshotMessage *)takeSnapshot:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable TrackCountMessage *)getSpuTracksCount:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable SpuTracksMessage *)getSpuTracks:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)setSpuTrack:(SpuTrackMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable SpuTrackMessage *)getSpuTrack:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)setSpuDelay:(DelayMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable DelayMessage *)getSpuDelay:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)addSubtitleTrack:(AddSubtitleMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable TrackCountMessage *)getAudioTracksCount:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable AudioTracksMessage *)getAudioTracks:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)setAudioTrack:(AudioTrackMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable AudioTrackMessage *)getAudioTrack:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)setAudioDelay:(DelayMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable DelayMessage *)getAudioDelay:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)addAudioTrack:(AddAudioMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable TrackCountMessage *)getVideoTracksCount:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable VideoTracksMessage *)getVideoTracks:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)setVideoTrack:(VideoTrackMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable VideoTrackMessage *)getVideoTrack:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)setVideoScale:(VideoScaleMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable VideoScaleMessage *)getVideoScale:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)setVideoAspectRatio:(VideoAspectRatioMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable VideoAspectRatioMessage *)getVideoAspectRatio:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable RendererServicesMessage *)getAvailableRendererServices:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)startRendererScanning:(RendererScanningMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)stopRendererScanning:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable RendererDevicesMessage *)getRendererDevices:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)castToRenderer:(RenderDeviceMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable BooleanMessage *)startRecording:(RecordMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable BooleanMessage *)stopRecording:(ViewMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
@end

extern void VlcPlayerApiSetup(id<FlutterBinaryMessenger> binaryMessenger, id<VlcPlayerApi> _Nullable api);

NS_ASSUME_NONNULL_END
