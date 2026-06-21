import CoreGraphics

struct ShufflePose {
    let center: CGPoint
    let rotation: Double
    let scale: CGFloat
    let zIndex: Double
}

enum ShufflePlanner {
    static func localProgress(
        for introOrder: Int,
        elapsed: Double,
        duration: Double,
        reduceMotion: Bool
    ) -> Double {
        if reduceMotion {
            return clamp(elapsed / max(duration, 0.01))
        }

        let delay = Double(introOrder) * GameTuning.shufflePerCardDelay
        let travelWindow = max(duration - Double(GameTuning.cardCount - 1) * GameTuning.shufflePerCardDelay, 0.35)
        return clamp((elapsed - delay) / travelWindow)
    }

    static func pose(
        for introOrder: Int,
        finalFrame: CGRect,
        boardSize: CGSize,
        progress: Double,
        reduceMotion: Bool
    ) -> ShufflePose {
        let finalCenter = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        let center = CGPoint(x: boardSize.width / 2, y: boardSize.height / 2)
        let clamped = clamp(progress)

        if reduceMotion {
            let eased = smoothStep(0.0, 1.0, clamped)
            let start = CGPoint(x: center.x, y: center.y + 22)
            return ShufflePose(
                center: interpolate(start, finalCenter, eased),
                rotation: 0,
                scale: CGFloat(0.985 + 0.015 * eased),
                zIndex: Double(100 - introOrder)
            )
        }

        let row = introOrder / GameTuning.columns
        let column = introOrder % GameTuning.columns
        let rowBias = CGFloat(row) - CGFloat(GameTuning.rows - 1) / 2
        let columnBias = CGFloat(column) - CGFloat(GameTuning.columns - 1) / 2
        let side: CGFloat = introOrder.isMultiple(of: 2) ? -1 : 1

        let phaseAngle = Double(introOrder) / Double(GameTuning.cardCount) * (.pi * 2)
        let start = CGPoint(
            x: center.x + cos(phaseAngle) * boardSize.width * 0.085,
            y: center.y + sin(phaseAngle * 1.15) * boardSize.height * 0.06
        )

        let control1 = CGPoint(
            x: center.x + side * boardSize.width * 0.2 * GameTuning.shuffleMotionIntensity,
            y: center.y - rowBias * finalFrame.height * 0.72 + columnBias * 5
        )

        let control2 = CGPoint(
            x: finalCenter.x - side * boardSize.width * 0.1 * GameTuning.shuffleMotionIntensity,
            y: finalCenter.y + rowBias * finalFrame.height * 0.18
        )

        let travel = smoothStep(0.02, 0.92, clamped)
        var current = cubicBezier(start, control1, control2, finalCenter, travel)

        let swirlFade = 1 - smoothStep(0.55, 1.0, clamped)
        let theta = phaseAngle + travel * (.pi * 2.05)

        current.x += CGFloat(cos(theta) * Double(boardSize.width * 0.026) * Double(swirlFade))
        current.y += CGFloat(sin(theta * 1.38) * Double(boardSize.height * 0.02) * Double(swirlFade))
        current.y += columnBias * 2.0 * swirlFade

        let rotation =
            sin(theta * 0.88) * 6.2 * Double(swirlFade) +
            Double(columnBias) * 1.1 * Double(1 - travel)

        let scale = CGFloat(0.93 + 0.07 * smoothStep(0.08, 0.88, clamped))
        let zIndex = Double(100 - introOrder) * Double(1 - travel) + Double(introOrder)

        return ShufflePose(center: current, rotation: rotation, scale: scale, zIndex: zIndex)
    }

    static func finalPose(for frame: CGRect) -> ShufflePose {
        ShufflePose(
            center: CGPoint(x: frame.midX, y: frame.midY),
            rotation: 0,
            scale: 1,
            zIndex: 0
        )
    }

    private static func cubicBezier(_ p0: CGPoint, _ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint, _ t: Double) -> CGPoint {
        let u = 1 - t
        let tt = t * t
        let uu = u * u
        let uuu = uu * u
        let ttt = tt * t

        return CGPoint(
            x: CGFloat(uuu) * p0.x + CGFloat(3 * uu * t) * p1.x + CGFloat(3 * u * tt) * p2.x + CGFloat(ttt) * p3.x,
            y: CGFloat(uuu) * p0.y + CGFloat(3 * uu * t) * p1.y + CGFloat(3 * u * tt) * p2.y + CGFloat(ttt) * p3.y
        )
    }

    private static func interpolate(_ start: CGPoint, _ end: CGPoint, _ progress: Double) -> CGPoint {
        CGPoint(
            x: start.x + (end.x - start.x) * CGFloat(progress),
            y: start.y + (end.y - start.y) * CGFloat(progress)
        )
    }

    private static func smoothStep(_ edge0: Double, _ edge1: Double, _ value: Double) -> Double {
        let normalized = clamp((value - edge0) / (edge1 - edge0))
        return normalized * normalized * (3 - 2 * normalized)
    }

    private static func smoothStep(_ edge0: Double, _ edge1: Double, _ value: CGFloat) -> CGFloat {
        CGFloat(smoothStep(edge0, edge1, Double(value)))
    }

    private static func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }
}
