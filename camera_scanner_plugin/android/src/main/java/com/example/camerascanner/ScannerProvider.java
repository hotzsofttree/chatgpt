package com.example.camerascanner;

import android.content.Context;

public abstract class ScannerProvider {
    protected Context context;

    public ScannerProvider(Context ctx) { this.context = ctx; }

    public abstract void startScan(ScanCallback callback);
    public abstract void stopScan();
    public abstract void dispose();

    // Reflection-based loader: flavor implementations should provide
    // class com.example.camerascanner.ScannerProviderImpl with a
    // single-argument constructor(Context).
    public static ScannerProvider getInstance(Context ctx) {
        try {
            Class<?> cls = Class.forName("com.example.camerascanner.ScannerProviderImpl");
            java.lang.reflect.Constructor<?> ctor = cls.getConstructor(Context.class);
            return (ScannerProvider) ctor.newInstance(ctx);
        } catch (Exception e) {
            throw new RuntimeException("No flavor implementation found for ScannerProvider: " + e.getMessage(), e);
        }
    }
}
