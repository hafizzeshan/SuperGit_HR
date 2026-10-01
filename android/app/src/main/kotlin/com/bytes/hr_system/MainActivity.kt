package com.bytes.supergithr

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Android 15+ ignores `navigationBarColor` and expects every app to
        // draw behind the system bars. Without this the window stops above the
        // gesture bar and that strip is left black. Flutter's own
        // `SystemUiMode.edgeToEdge` did not take effect here, so the window is
        // told directly. Content keeps clear of the bars through the insets in
        // `lib/views/safe_insets.dart`.
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }
}
