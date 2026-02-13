package com.example.camerascanner;

import android.content.Context;

public class ScannerProviderImpl extends ScannerProvider {
    public ScannerProviderImpl(Context ctx) { super(ctx); }

    @Override
    public void startScan(ScanCallback callback) {
        // Stubbed IMIN implementation
        callback.onScanned("IMIN:mock_barcode_ABCDE");
    }

    @Override
    public void stopScan() { }

    @Override
    public void dispose() { }
}
