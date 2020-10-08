//
//  EyeTrackController.swift
//
//
//  Created by Yuki Yamato on 2020/10/01.
//

import Foundation
import SwiftUI
import Combine



@available(iOS 13.0, *)
public class EyeTrackController: ObservableObject {
    @Published public var eyeTrack: EyeTrack
    private var _view: EyeTrackView?
    private var isVideoRecording: Bool = true
    private var isHidden: Bool
    var anyCancellable: AnyCancellable? = nil

    public var onUpdate: (EyeTrackInfo?) -> Void {
        get {
            return self.eyeTrack.onUpdate
        }
        set {
            self.eyeTrack.onUpdate = newValue
        }
    }

    public init(type: DeviceType, smoothingRange: Int, blinkThreshold: Float, isHidden: Bool = true) {
        eyeTrack = EyeTrack(type: .iPhone, smoothingRange: 10, blinkThreshold: 0.4)
        self.isHidden = isHidden
        anyCancellable = eyeTrack.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
    }

    public var view: EyeTrackView {
        get {
            if self._view == nil {
                self._view = EyeTrackView(isHidden: isHidden, eyeTrack: eyeTrack)
            }
            return self._view!
        }
    }

    public func hide() -> Void {
        self._view?.hide()
    }

    public func show() -> Void {
        self._view?.show()
    }

    public func showRayHint() -> Void {
        self.eyeTrack.showRayHint()
    }

    public func hideRayHint() -> Void {
        self.eyeTrack.hideRayHint()
    }

    /// start to record data
    public func start(videoRecording: Bool = true) -> Void {
        isVideoRecording = videoRecording
        if isVideoRecording {
            view.startRecord()
        }
        self.eyeTrack.setStatus(status: .RECORDING)
    }

    public func stop(finished: @escaping (URL) -> Void = { _ in }, isExport: Bool = false) -> Void {
        self.eyeTrack.setStatus(status: .RECORDED)
        print("Acquired \(self.eyeTrack.data.count) frames")
        if isVideoRecording {
            view.stopRecord(finished: finished, isExport: isExport)
        }
    }

    public func reset() -> Void {
        self.eyeTrack.frame = 0
        self.eyeTrack.setStatus(status: .STANDBY)
    }

    public var currentInfo: EyeTrackInfo? {
        return self.eyeTrack.info
    }

}
