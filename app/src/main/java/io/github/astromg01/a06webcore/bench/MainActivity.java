package io.github.astromg01.a06webcore.bench;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Debug;
import android.os.SystemClock;
import android.text.TextUtils;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.WindowInsets;
import android.webkit.ConsoleMessage;
import android.webkit.RenderProcessGoneDetail;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.webkit.WebViewFeature;

import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.time.Instant;

public final class MainActivity extends Activity {
    private static final String TEST_ORIGIN = "https://a06webcore.local/";

    private LinearLayout content;
    private TextView providerView;
    private TextView statusView;
    private TextView reportView;
    private Button runButton;
    private Button copyButton;
    private Button shareButton;
    private WebView webView;

    private boolean pageReady;
    private int rendererCrashCount;
    private long pageLoadMs = -1L;
    private long pageLoadStartedAt;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        ScrollView scrollView = new ScrollView(this);
        scrollView.setFillViewport(true);
        scrollView.setBackgroundColor(Color.rgb(16, 24, 32));

        content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        content.setPadding(dp(16), dp(18), dp(16), dp(24));
        scrollView.addView(content, new ScrollView.LayoutParams(
                ScrollView.LayoutParams.MATCH_PARENT,
                ScrollView.LayoutParams.WRAP_CONTENT
        ));
        setContentView(scrollView);

        scrollView.setOnApplyWindowInsetsListener((view, insets) -> {
            int left;
            int top;
            int right;
            int bottom;
            if (Build.VERSION.SDK_INT >= 30) {
                android.graphics.Insets bars = insets.getInsets(WindowInsets.Type.systemBars());
                left = bars.left;
                top = bars.top;
                right = bars.right;
                bottom = bars.bottom;
            } else {
                left = insets.getSystemWindowInsetLeft();
                top = insets.getSystemWindowInsetTop();
                right = insets.getSystemWindowInsetRight();
                bottom = insets.getSystemWindowInsetBottom();
            }
            view.setPadding(dp(16) + left, dp(18) + top, dp(16) + right, dp(24) + bottom);
            return insets;
        });

        buildUi();
        configureWebView();
        loadDiagnosticPage();
        refreshProviderSummary();
    }

    private void buildUi() {
        TextView title = text("A06 WebCore", 26, Color.WHITE, true);
        content.addView(title, matchWrap());
        TextView subtitle = text("DIAGNÓSTICO DO MOTOR WEBVIEW · ANDROID 16", 11,
                Color.rgb(128, 203, 196), true);
        LinearLayout.LayoutParams subtitleParams = matchWrap();
        subtitleParams.topMargin = dp(4);
        content.addView(subtitle, subtitleParams);

        TextView explanation = text(
                "Ferramenta técnica para medir o provedor WebView instalado. "
                        + "Não é um navegador e não substitui o provedor do sistema.",
                14, Color.rgb(190, 203, 210), false
        );
        LinearLayout.LayoutParams explanationParams = matchWrap();
        explanationParams.topMargin = dp(12);
        explanationParams.bottomMargin = dp(14);
        content.addView(explanation, explanationParams);

        providerView = text("Identificando provedor WebView…", 13,
                Color.rgb(232, 240, 242), false);
        providerView.setPadding(dp(14), dp(14), dp(14), dp(14));
        providerView.setBackground(cardBackground());
        content.addView(providerView, matchWrap());

        runButton = button("Executar bateria de testes");
        LinearLayout.LayoutParams runParams = matchWrap();
        runParams.topMargin = dp(14);
        content.addView(runButton, runParams);
        runButton.setOnClickListener(view -> runBenchmark());

        LinearLayout actions = new LinearLayout(this);
        actions.setOrientation(LinearLayout.HORIZONTAL);
        actions.setGravity(Gravity.CENTER);
        LinearLayout.LayoutParams actionsParams = matchWrap();
        actionsParams.topMargin = dp(8);
        content.addView(actions, actionsParams);

        copyButton = button("Copiar relatório");
        shareButton = button("Compartilhar");
        LinearLayout.LayoutParams actionButtonParams = new LinearLayout.LayoutParams(
                0, dp(48), 1f
        );
        actionButtonParams.setMargins(0, 0, dp(5), 0);
        actions.addView(copyButton, actionButtonParams);
        LinearLayout.LayoutParams shareParams = new LinearLayout.LayoutParams(
                0, dp(48), 1f
        );
        shareParams.setMargins(dp(5), 0, 0, 0);
        actions.addView(shareButton, shareParams);

        copyButton.setEnabled(false);
        shareButton.setEnabled(false);
        copyButton.setOnClickListener(view -> copyReport());
        shareButton.setOnClickListener(view -> shareReport());

        statusView = text("Aguardando carregamento dos testes locais…", 12,
                Color.rgb(128, 203, 196), false);
        LinearLayout.LayoutParams statusParams = matchWrap();
        statusParams.topMargin = dp(12);
        statusParams.bottomMargin = dp(8);
        content.addView(statusView, statusParams);

        TextView testSurfaceLabel = text("SUPERFÍCIE DE TESTE LOCAL", 10,
                Color.rgb(144, 164, 174), true);
        LinearLayout.LayoutParams labelParams = matchWrap();
        labelParams.topMargin = dp(8);
        labelParams.bottomMargin = dp(6);
        content.addView(testSurfaceLabel, labelParams);

        reportView = text("Nenhum teste executado ainda.", 12,
                Color.rgb(220, 230, 234), false);
        reportView.setTypeface(android.graphics.Typeface.MONOSPACE);
        reportView.setTextIsSelectable(true);
        reportView.setPadding(dp(12), dp(12), dp(12), dp(12));
        reportView.setBackground(cardBackground());
        LinearLayout.LayoutParams reportParams = matchWrap();
        reportParams.bottomMargin = dp(14);
        content.addView(reportView, reportParams);

        webView = new WebView(this);
        webView.setBackgroundColor(Color.rgb(16, 24, 32));
        webView.setVerticalScrollBarEnabled(false);
        webView.setHorizontalScrollBarEnabled(false);
        LinearLayout.LayoutParams webParams = new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, dp(210)
        );
        content.addView(webView, webParams);
    }

    private void configureWebView() {
        WebView.setWebContentsDebuggingEnabled(false);

        WebSettings settings = webView.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setAllowFileAccess(false);
        settings.setAllowContentAccess(false);
        settings.setAllowFileAccessFromFileURLs(false);
        settings.setAllowUniversalAccessFromFileURLs(false);
        settings.setJavaScriptCanOpenWindowsAutomatically(false);
        settings.setSupportMultipleWindows(false);
        settings.setGeolocationEnabled(false);
        settings.setMediaPlaybackRequiresUserGesture(true);
        settings.setBlockNetworkLoads(true);
        settings.setMixedContentMode(WebSettings.MIXED_CONTENT_NEVER_ALLOW);
        settings.setSafeBrowsingEnabled(true);
        settings.setLoadsImagesAutomatically(false);
        settings.setSupportZoom(false);

        webView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageStarted(WebView view, String url, android.graphics.Bitmap favicon) {
                pageReady = false;
                pageLoadStartedAt = SystemClock.elapsedRealtime();
                statusView.setText("Carregando superfície de diagnóstico…");
            }

            @Override
            public void onPageFinished(WebView view, String url) {
                pageLoadMs = SystemClock.elapsedRealtime() - pageLoadStartedAt;
                pageReady = true;
                statusView.setText("Superfície pronta. Provedor: " + providerLabel());
                runButton.setEnabled(true);
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                Uri uri = request.getUrl();
                boolean localOrigin = "https".equalsIgnoreCase(uri.getScheme())
                        && "a06webcore.local".equalsIgnoreCase(uri.getHost());
                return !localOrigin;
            }

            @Override
            public boolean onRenderProcessGone(WebView view, RenderProcessGoneDetail detail) {
                rendererCrashCount++;
                pageReady = false;
                runButton.setEnabled(false);
                statusView.setText("O processo de renderização foi encerrado. "
                        + "Crashes registrados: " + rendererCrashCount);
                reportView.setText("Render process gone. didCrash="
                        + detail.didCrash() + ", priorityAtExit="
                        + detail.rendererPriorityAtExit());
                return true;
            }
        });

        webView.setWebChromeClient(new WebChromeClient() {
            @Override
            public boolean onConsoleMessage(ConsoleMessage consoleMessage) {
                android.util.Log.d("A06WebCoreBench",
                        consoleMessage.message() + " @ " + consoleMessage.lineNumber());
                return true;
            }
        });

        runButton.setEnabled(false);
    }

    private void loadDiagnosticPage() {
        try (InputStream input = getAssets().open("bench.html");
             ByteArrayOutputStream output = new ByteArrayOutputStream()) {
            byte[] buffer = new byte[4096];
            int read;
            while ((read = input.read(buffer)) != -1) {
                output.write(buffer, 0, read);
            }
            String html = output.toString(StandardCharsets.UTF_8.name());
            webView.loadDataWithBaseURL(TEST_ORIGIN, html, "text/html", "UTF-8", null);
        } catch (IOException error) {
            statusView.setText("Falha ao abrir testes locais: " + error.getMessage());
        }
    }

    private void runBenchmark() {
        if (!pageReady || webView == null) {
            statusView.setText("A superfície ainda não está pronta.");
            return;
        }

        runButton.setEnabled(false);
        copyButton.setEnabled(false);
        shareButton.setEnabled(false);
        statusView.setText("Executando testes de JavaScript, DOM, Canvas, WebGL e APIs…");

        final long pssBefore = Debug.getPss();
        final long startedAt = SystemClock.elapsedRealtime();

        webView.evaluateJavascript(
                "JSON.stringify(window.__a06WebCoreBench.run())",
                rawResult -> {
                    try {
                        Object decoded = new JSONTokener(rawResult).nextValue();
                        String jsonText = decoded instanceof String
                                ? (String) decoded : String.valueOf(decoded);
                        JSONObject webResult = new JSONObject(jsonText);

                        JSONObject report = createDeviceReport();
                        report.put("page_load_ms", pageLoadMs);
                        report.put("benchmark_execution_ms",
                                SystemClock.elapsedRealtime() - startedAt);
                        report.put("web_runtime", webResult);
                        report.put("memory_pss_before_kb", pssBefore);
                        report.put("memory_pss_after_kb", Debug.getPss());
                        report.put("renderer_crash_count", rendererCrashCount);
                        report.put("security_configuration", collectSecurityConfiguration());

                        String formatted = report.toString(2);
                        reportView.setText(formatted);
                        statusView.setText(buildSummary(webResult));
                        copyButton.setEnabled(true);
                        shareButton.setEnabled(true);
                    } catch (Exception error) {
                        statusView.setText("Falha ao interpretar o resultado: "
                                + error.getMessage());
                        reportView.setText(rawResult == null ? "(sem resultado)" : rawResult);
                    } finally {
                        runButton.setEnabled(pageReady);
                    }
                }
        );
    }

    private JSONObject createDeviceReport() throws JSONException {
        JSONObject report = new JSONObject();
        JSONObject device = new JSONObject();
        JSONObject provider = new JSONObject();
        JSONObject app = new JSONObject();
        ActivityManager manager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
        ActivityManager.MemoryInfo memoryInfo = new ActivityManager.MemoryInfo();
        manager.getMemoryInfo(memoryInfo);

        device.put("manufacturer", Build.MANUFACTURER);
        device.put("model", Build.MODEL);
        device.put("device", Build.DEVICE);
        device.put("android_release", Build.VERSION.RELEASE);
        device.put("sdk_int", Build.VERSION.SDK_INT);
        device.put("security_patch", Build.VERSION.SECURITY_PATCH);
        device.put("supported_abis", TextUtils.join(",", Build.SUPPORTED_ABIS));
        device.put("total_ram_bytes", memoryInfo.totalMem);
        device.put("available_ram_bytes", memoryInfo.availMem);
        device.put("low_memory_state", memoryInfo.lowMemory);
        device.put("is_low_ram_device", manager.isLowRamDevice());
        device.put("memory_class_mb", manager.getMemoryClass());
        device.put("large_memory_class_mb", manager.getLargeMemoryClass());

        PackageInfo providerInfo = WebView.getCurrentWebViewPackage();
        if (providerInfo != null) {
            provider.put("package_name", providerInfo.packageName);
            provider.put("version_name", providerInfo.versionName);
            provider.put("version_code", Build.VERSION.SDK_INT >= 28
                    ? providerInfo.getLongVersionCode() : providerInfo.versionCode);
        } else {
            provider.put("available", false);
        }

        app.put("package_name", getPackageName());
        app.put("version_name", BuildConfig.VERSION_NAME);
        app.put("version_code", BuildConfig.VERSION_CODE);
        app.put("chromium_baseline", BuildConfig.CHROMIUM_BASELINE);

        report.put("schema_version", 1);
        report.put("generated_at_utc", Instant.now().toString());
        report.put("device", device);
        report.put("provider", provider);
        report.put("diagnostic_app", app);
        report.put("user_agent", webView.getSettings().getUserAgentString());
        return report;
    }

    private JSONObject collectSecurityConfiguration() throws JSONException {
        JSONObject security = new JSONObject();
        WebSettings settings = webView.getSettings();
        security.put("javascript_enabled_for_local_harness", settings.getJavaScriptEnabled());
        security.put("file_access", settings.getAllowFileAccess());
        security.put("content_access", settings.getAllowContentAccess());
        security.put("file_access_from_file_urls", settings.getAllowFileAccessFromFileURLs());
        security.put("universal_access_from_file_urls",
                settings.getAllowUniversalAccessFromFileURLs());
        security.put("network_loads_blocked", true);
        security.put("mixed_content_mode", settings.getMixedContentMode());
        security.put("safe_browsing_enabled", settings.getSafeBrowsingEnabled());
        security.put("javascript_bridge_installed", false);
        security.put("web_contents_debugging_enabled", false);

        JSONObject features = new JSONObject();
        addFeature(features, "SAFE_BROWSING_ENABLE", WebViewFeature.SAFE_BROWSING_ENABLE);
        addFeature(features, "ALGORITHMIC_DARKENING", WebViewFeature.ALGORITHMIC_DARKENING);
        addFeature(features, "OFF_SCREEN_PRERASTER", WebViewFeature.OFF_SCREEN_PRERASTER);
        addFeature(features, "WEB_MESSAGE_LISTENER", WebViewFeature.WEB_MESSAGE_LISTENER);
        addFeature(features, "DOCUMENT_START_SCRIPT", WebViewFeature.DOCUMENT_START_SCRIPT);
        addFeature(features, "VISUAL_STATE_CALLBACK", WebViewFeature.VISUAL_STATE_CALLBACK);
        security.put("androidx_webkit_features", features);
        return security;
    }

    private void addFeature(JSONObject target, String label, String feature) throws JSONException {
        target.put(label, WebViewFeature.isFeatureSupported(feature));
    }

    private String buildSummary(JSONObject result) {
        JSONObject features = result.optJSONObject("features");
        JSONObject benchmarks = result.optJSONObject("benchmarks");
        if (features == null || benchmarks == null) {
            return "Testes concluídos. Consulte o relatório JSON.";
        }
        return "Testes concluídos · JS "
                + benchmarks.optString("javascript_400k_ms", "?") + " ms · Canvas "
                + benchmarks.optString("canvas_1500_rects_ms", "?") + " ms · WebGL2 "
                + features.optBoolean("webgl2") + " · WASM "
                + features.optBoolean("webassembly_module");
    }

    private String providerLabel() {
        PackageInfo info = WebView.getCurrentWebViewPackage();
        if (info == null) {
            return "não identificado";
        }
        return info.packageName + " (" + info.versionName + ")";
    }

    private void refreshProviderSummary() {
        providerView.setText(
                "PROVEDOR ATIVO\n" + providerLabel()
                        + "\nAparelho: " + Build.MANUFACTURER + " " + Build.MODEL
                        + "\nAndroid: " + Build.VERSION.RELEASE + " (API "
                        + Build.VERSION.SDK_INT + ")"
                        + "\nChromium de referência do projeto: "
                        + BuildConfig.CHROMIUM_BASELINE
        );
    }

    private void copyReport() {
        CharSequence report = reportView.getText();
        if (TextUtils.isEmpty(report) || "Nenhum teste executado ainda.".contentEquals(report)) {
            return;
        }
        ClipboardManager clipboard =
                (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
        clipboard.setPrimaryClip(ClipData.newPlainText("A06 WebCore report", report));
        Toast.makeText(this, "Relatório copiado.", Toast.LENGTH_SHORT).show();
    }

    private void shareReport() {
        CharSequence report = reportView.getText();
        if (TextUtils.isEmpty(report)) {
            return;
        }
        Intent intent = new Intent(Intent.ACTION_SEND);
        intent.setType("text/plain");
        intent.putExtra(Intent.EXTRA_SUBJECT, "A06 WebCore WebView diagnostics");
        intent.putExtra(Intent.EXTRA_TEXT, report.toString());
        startActivity(Intent.createChooser(intent, "Compartilhar relatório"));
    }

    private TextView text(String value, int sizeSp, int color, boolean bold) {
        TextView view = new TextView(this);
        view.setText(value);
        view.setTextSize(TypedValue.COMPLEX_UNIT_SP, sizeSp);
        view.setTextColor(color);
        if (bold) {
            view.setTypeface(android.graphics.Typeface.DEFAULT, android.graphics.Typeface.BOLD);
        }
        return view;
    }

    private Button button(String label) {
        Button button = new Button(this);
        button.setText(label);
        button.setTextSize(TypedValue.COMPLEX_UNIT_SP, 13);
        button.setAllCaps(false);
        button.setTextColor(Color.rgb(16, 32, 38));
        button.setBackground(buttonBackground());
        button.setPadding(dp(8), dp(4), dp(8), dp(4));
        return button;
    }

    private GradientDrawable cardBackground() {
        GradientDrawable drawable = new GradientDrawable();
        drawable.setColor(Color.rgb(23, 35, 44));
        drawable.setCornerRadius(dp(12));
        drawable.setStroke(dp(1), Color.rgb(52, 67, 75));
        return drawable;
    }

    private GradientDrawable buttonBackground() {
        GradientDrawable drawable = new GradientDrawable();
        drawable.setColor(Color.rgb(128, 203, 196));
        drawable.setCornerRadius(dp(10));
        return drawable;
    }

    private LinearLayout.LayoutParams matchWrap() {
        return new LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
        );
    }

    private int dp(int value) {
        return Math.round(value * getResources().getDisplayMetrics().density);
    }

    @Override
    protected void onDestroy() {
        if (webView != null) {
            webView.stopLoading();
            webView.setWebChromeClient(null);
            webView.setWebViewClient(null);
            webView.destroy();
            webView = null;
        }
        super.onDestroy();
    }
}
