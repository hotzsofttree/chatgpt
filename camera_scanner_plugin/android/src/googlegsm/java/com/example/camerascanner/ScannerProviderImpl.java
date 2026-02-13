package com.example.camerascanner;

import android.content.Context;

public class ScannerProviderImpl extends ScannerProvider {
    public ScannerProviderImpl(Context ctx) { super(ctx); }

    @Override
    public void startScan(ScanCallback callback) {
        // Stubbed GoogleGSM implementation (e.g., using camera + ML Kit)
        callback.onScanned("GOOGLGSM:mock_barcode_ZYXWV");
    }

    @Override
    public void stopScan() { }

    @Override
    public void dispose() { }
}
