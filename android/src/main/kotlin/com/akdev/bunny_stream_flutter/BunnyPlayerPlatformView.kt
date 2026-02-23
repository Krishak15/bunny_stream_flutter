package com.akdev.bunny_stream_flutter

import android.annotation.SuppressLint
import android.app.Activity
import android.content.res.ColorStateList
import android.content.Context
import android.content.ContextWrapper
import android.graphics.Color
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import io.flutter.plugin.platform.PlatformView
import net.bunny.bunnystreamplayer.ui.BunnyStreamPlayer
import java.lang.reflect.Method

@SuppressLint("SetTextI18n")
class BunnyPlayerPlatformView(
  context: Context,
  creationParams: Map<String, Any?>?,
) : PlatformView {
  companion object {
    private const val TAG = "BunnyPlayerPlatformView"
  }

  private val rootView: FrameLayout

  init {
    val videoId = (creationParams?.get("videoId") as? String)?.trim().orEmpty()
    val libraryId = (creationParams?.get("libraryId") as? Number)?.toLong() ?: 0L
    val accessKey = (creationParams?.get("accessKey") as? String)?.trim().orEmpty()
    val token = (creationParams?.get("token") as? String)?.trim()?.ifBlank { null }
    val expires = (creationParams?.get("expires") as? Number)?.toLong()

    val themedContext = getActivityFromContext(context) ?: context

    rootView = FrameLayout(themedContext).apply {
      layoutParams = FrameLayout.LayoutParams(
        FrameLayout.LayoutParams.MATCH_PARENT,
        FrameLayout.LayoutParams.MATCH_PARENT,
      )
    }

    try {
      val playerView = BunnyStreamPlayer(themedContext).apply {
        layoutParams = FrameLayout.LayoutParams(
          FrameLayout.LayoutParams.MATCH_PARENT,
          FrameLayout.LayoutParams.MATCH_PARENT,
        )
      }
      rootView.addView(playerView)
      applyLightTintToControlIcons(playerView)
      playerView.addOnLayoutChangeListener { _, _, _, _, _, _, _, _, _ ->
        applyLightTintToControlIcons(playerView)
      }

      if (videoId.isNotEmpty() && libraryId > 0L) {
        initializeBunnySdkIfAvailable(themedContext, accessKey, libraryId)
        rootView.post {
          try {
            applyLightTintToControlIcons(playerView)
            playerView.playVideo(videoId, libraryId, "", token, expires)
          } catch (playError: Throwable) {
            Log.e(TAG, "Failed to start Bunny video playback", playError)
          }
        }
      }
    } catch (error: Throwable) {
      Log.e(TAG, "Failed to initialize Bunny native player", error)
      var nested = error.cause
      while (nested != null) {
        Log.e(TAG, "Nested cause: ${nested::class.java.name}: ${nested.message}", nested)
        nested = nested.cause
      }
      val fallbackView = TextView(themedContext).apply {
        layoutParams = FrameLayout.LayoutParams(
          FrameLayout.LayoutParams.MATCH_PARENT,
          FrameLayout.LayoutParams.MATCH_PARENT,
        )
        text = "Failed to initialize Bunny built-in player. Check theme and SDK setup."
        textAlignment = View.TEXT_ALIGNMENT_CENTER
      }
      rootView.addView(fallbackView)
    }
  }

  override fun getView(): View = rootView

  private fun getActivityFromContext(context: Context): Activity? {
    var current = context
    while (current is ContextWrapper) {
      if (current is Activity) {
        return current
      }
      current = current.baseContext
    }
    return null
  }

  private fun initializeBunnySdkIfAvailable(context: Context, accessKey: String, libraryId: Long) {
    val classCandidates = listOf(
      "net.bunny.api.BunnyStreamSdk",
      "net.bunny.api.BunnyStreamApi",
      "net.bunnystream.api.BunnyStreamApi",
    )

    for (className in classCandidates) {
      try {
        val clazz = Class.forName(className)
        if (invokeInitializeOnClass(clazz, context, accessKey, libraryId)) {
          Log.d(TAG, "Initialized Bunny SDK using $className")
          return
        }

        val companion = clazz.declaredFields.firstOrNull { it.name == "Companion" }?.let { field ->
          field.isAccessible = true
          field.get(null)
        }

        if (companion != null && invokeInitializeOnInstance(companion, context, accessKey, libraryId)) {
          Log.d(TAG, "Initialized Bunny SDK using $className.Companion")
          return
        }
      } catch (_: ClassNotFoundException) {
      } catch (error: Throwable) {
        Log.w(TAG, "Failed Bunny SDK initialization attempt for $className", error)
      }
    }
  }

  private fun applyLightTintToControlIcons(root: View) {
    val targetColor = Color.WHITE

    fun traverse(view: View) {
      if (view is ImageView && view.isClickable && view.drawable != null) {
        view.imageTintList = ColorStateList.valueOf(targetColor)
        view.setColorFilter(targetColor)
      }

      if (view is ViewGroup) {
        for (index in 0 until view.childCount) {
          traverse(view.getChildAt(index))
        }
      }
    }

    traverse(root)
  }

  private fun invokeInitializeOnClass(
    clazz: Class<*>,
    context: Context,
    accessKey: String,
    libraryId: Long,
  ): Boolean {
    return runCatching {
      val method = resolveInitializeMethod(clazz)
      invokeInitialize(method, null, context, accessKey, libraryId)
      true
    }.getOrElse { false }
  }

  private fun invokeInitializeOnInstance(
    instance: Any,
    context: Context,
    accessKey: String,
    libraryId: Long,
  ): Boolean {
    return runCatching {
      val method = resolveInitializeMethod(instance.javaClass)
      invokeInitialize(method, instance, context, accessKey, libraryId)
      true
    }.getOrElse { false }
  }

  private fun resolveInitializeMethod(targetClass: Class<*>): Method {
    val candidates = targetClass.methods.filter { method ->
      method.name == "initialize" || method.name == "init"
    }

    return candidates.firstOrNull { method ->
      val params = method.parameterTypes
      params.size == 3 &&
        Context::class.java.isAssignableFrom(params[0]) &&
        (params[1] == String::class.java) &&
        (params[2] == java.lang.Long.TYPE || params[2] == java.lang.Long::class.java)
    } ?: candidates.firstOrNull { method ->
      val params = method.parameterTypes
      params.size == 2 &&
        Context::class.java.isAssignableFrom(params[0]) &&
        (params[1] == String::class.java)
    } ?: candidates.firstOrNull { method ->
      val params = method.parameterTypes
      params.size == 2 &&
        Context::class.java.isAssignableFrom(params[0]) &&
        (params[1] == java.lang.Long.TYPE || params[1] == java.lang.Long::class.java)
    } ?: candidates.firstOrNull { method ->
      val params = method.parameterTypes
      params.size == 1 && Context::class.java.isAssignableFrom(params[0])
    } ?: throw NoSuchMethodException("No suitable initialize/init method found on ${targetClass.name}")
  }

  private fun invokeInitialize(
    method: Method,
    receiver: Any?,
    context: Context,
    accessKey: String,
    libraryId: Long,
  ) {
    val args = when (method.parameterTypes.size) {
      3 -> arrayOf(context, accessKey, libraryId)
      2 -> {
        val second = method.parameterTypes[1]
        if (second == String::class.java) {
          arrayOf(context, accessKey)
        } else {
          arrayOf(context, libraryId)
        }
      }
      1 -> arrayOf(context)
      else -> throw NoSuchMethodException("Unsupported initialize signature on ${method.declaringClass.name}")
    }
    method.invoke(receiver, *args)
  }

  override fun dispose() {}
}
