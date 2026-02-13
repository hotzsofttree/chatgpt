package com.example.camerascanner;

import android.content.Context;

public class ScannerProviderImpl extends ScannerProvider {
    public ScannerProviderImpl(Context ctx) { super(ctx); }

    @Override
    public void startScan(ScanCallback callback) {
        // Stubbed SUNMI implementation: in real code call SUNMI SDK
        callback.onScanned("SUNMI:mock_barcode_12345");
    }

    @Override
    public void stopScan() {
        // stop SUNMI scanning
    }

    @Override
    public void dispose() {
        // cleanup
    }
}
