#if os(iOS)
import SwiftUI
import AVFoundation

struct BarcodeScannerContainerView: View {
    let onCodeScanned: (String) -> Void

    var body: some View {
        BarcodeScannerView(onCodeScanned: onCodeScanned)
    }
}

struct BarcodeScannerView: View {
    let onCodeScanned: (String) -> Void

    @State private var isScanning = true
    @State private var scannedCode: String?
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            CameraPreviewRepresentable(
                isActive: isScanning,
                onCodeScanned: { code in
                    isScanning = false
                    scannedCode = code
                },
                onError: { message in
                    isScanning = false
                    errorMessage = message
                }
            )
            .ignoresSafeArea()

            overlayContent
        }
        .onChange(of: scannedCode) { _, code in
            if let code { onCodeScanned(code) }
        }
    }

    @ViewBuilder
    private var overlayContent: some View {
        VStack {
            Spacer()
            if let errorMessage {
                VStack(spacing: 12) {
                    Text(errorMessage)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        isScanning = true
                        scannedCode = nil
                        self.errorMessage = nil
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .padding()
            } else if isScanning {
                Text("Point camera at a barcode")
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - AVFoundation Camera

private struct CameraPreviewRepresentable: UIViewRepresentable {
    let isActive: Bool
    let onCodeScanned: (String) -> Void
    let onError: (String) -> Void

    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        view.onCodeScanned = onCodeScanned
        view.onError = onError
        view.startSession()
        return view
    }

    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        if isActive { uiView.resumeScanning() }
    }
}

final class CameraPreviewView: UIView {
    var onCodeScanned: ((String) -> Void)?
    var onError: ((String) -> Void)?

    private var session: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var hasScanned = false

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }

    func startSession() {
        let session = AVCaptureSession()

        guard let device = AVCaptureDevice.default(for: .video) else {
            onError?("No camera found")
            return
        }
        guard let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            onError?("Cannot access camera")
            return
        }
        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else {
            onError?("Cannot configure camera output")
            return
        }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.ean8, .ean13, .qr, .code128, .code39, .pdf417, .upce]

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = bounds
        layer.addSublayer(preview)

        self.session = session
        self.previewLayer = preview

        DispatchQueue.global(qos: .userInitiated).async { session.startRunning() }
    }

    func resumeScanning() {
        hasScanned = false
        guard let session, !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { session.startRunning() }
    }
}

extension CameraPreviewView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard !hasScanned,
              let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let code = obj.stringValue else { return }
        hasScanned = true
        session?.stopRunning()
        onCodeScanned?(code)
    }
}
#endif
