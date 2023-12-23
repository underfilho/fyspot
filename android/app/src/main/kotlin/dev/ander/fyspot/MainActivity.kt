package dev.ander.fyspot

import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
import com.google.gson.Gson
import com.spotify.android.appremote.api.ConnectionParams
import com.spotify.android.appremote.api.Connector
import com.spotify.android.appremote.api.SpotifyAppRemote
import com.spotify.protocol.client.Subscription
import com.spotify.protocol.types.PlayerState
import com.spotify.sdk.android.auth.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

private const val CHANNEL = "spotify"
private const val EVENT_CHANNEL = "spotify_player"
private const val CLIENT_ID = "9425dde2f84b4d798dc5822276e04b6d"
private const val REDIRECT_URI = "dev.ander.fyspot://callback"
private const val REQUEST_CODE = 1337

class MainActivity: FlutterActivity() {
    private var spotifyAppRemote: SpotifyAppRemote? = null
    private var tempResultForActivity: MethodChannel.Result? = null
    private var tempPlayerSubscription: Subscription<PlayerState>? = null
    private var gson = Gson()

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "initSpotify" -> initSpotify(result)
                "getSpotifyToken" -> getSpotifyToken(result)
                "stopSpotify" -> stopSpotify(result)
                "play" -> play(result, call.argument("uri") as String?)
                "pause" -> pause(result)
                "previous" -> previous(result)
                "next" -> next(result)
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(object :
            EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
                    tempPlayerSubscription = spotifyAppRemote?.playerApi?.subscribeToPlayerState()
                    tempPlayerSubscription?.setEventCallback {
                        eventSink.success(gson.toJson(it))
                    }
                }

                override fun onCancel(arguments: Any?) {
                    tempPlayerSubscription?.cancel()
                    tempPlayerSubscription = null
                }
            })
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if(requestCode != REQUEST_CODE) return

        val response = AuthorizationClient.getResponse(resultCode, data)
        when(response.type) {
            AuthorizationResponse.Type.TOKEN -> tempResultForActivity?.success(response.accessToken)
            AuthorizationResponse.Type.ERROR -> tempResultForActivity?.error("Error in Spotify Token", response.error, null)
            else -> tempResultForActivity?.error("Unknown error", null, null)
        }
    }

    private fun initSpotify(result: MethodChannel.Result) {
        if(spotifyAppRemote != null) return

        val connectionParams = ConnectionParams.Builder(CLIENT_ID)
            .setRedirectUri(REDIRECT_URI)
            .showAuthView(true)
            .build()

        SpotifyAppRemote.connect(this, connectionParams, object : Connector.ConnectionListener {
            override fun onConnected(appRemote: SpotifyAppRemote) {
                spotifyAppRemote = appRemote
                result.success(true);
            }

            override fun onFailure(throwable: Throwable) {
                result.success(false)
            }
        })
    }

    private fun stopSpotify(result: MethodChannel.Result) {
        if(spotifyAppRemote == null) return

        SpotifyAppRemote.disconnect(spotifyAppRemote)
        spotifyAppRemote = null
        result.success(true)
    }

    private fun getSpotifyToken(result: MethodChannel.Result) {
        val builder =
            AuthorizationRequest.Builder(CLIENT_ID, AuthorizationResponse.Type.TOKEN, REDIRECT_URI)

        builder.setScopes(arrayOf("streaming"))
        val request = builder.build()

        tempResultForActivity = result;
        AuthorizationClient.openLoginActivity(this, REQUEST_CODE, request)
    }

    private fun pause(result: MethodChannel.Result) {
        spotifyAppRemote?.playerApi?.pause()
        result.success(true)
    }

    private fun play(result: MethodChannel.Result, uri: String?) {
        if(uri == null) spotifyAppRemote?.playerApi?.resume()
        else spotifyAppRemote?.playerApi?.play(uri)
        result.success(true)
    }

    private fun previous(result: MethodChannel.Result) {
        spotifyAppRemote?.playerApi?.skipPrevious()
        result.success(true)
    }

    private fun next(result: MethodChannel.Result) {
        spotifyAppRemote?.playerApi?.skipNext()
        result.success(true)
    }
}
