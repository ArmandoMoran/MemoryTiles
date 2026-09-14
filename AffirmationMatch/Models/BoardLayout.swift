import CoreGraphics

struct BoardMetrics {
    let boardFrame: CGRect
    let cardSize: CGSize
    let spacing: CGFloat

    func frame(for index: Int) -> CGRect {
        let row = index / GameTuning.columns
        let column = index % GameTuning.columns

        let x = boardFrame.minX + CGFloat(column) * (cardSize.width + spacing)
        let y = boardFrame.minY + CGFloat(row) * (cardSize.height + spacing)

        return CGRect(origin: CGPoint(x: x, y: y), size: cardSize)
    }
}

enum BoardLayout {
    static func metrics(in size: CGSize) -> BoardMetrics {
        let spacing = adaptiveSpacing(for: size)
        let columns = CGFloat(GameTuning.columns)
        let rows = CGFloat(GameTuning.rows)
        let outerInset = min(10, max(5, min(size.width, size.height) * 0.018))
        let availableWidth = max(0, size.width - outerInset * 2)
        let availableHeight = max(0, size.height - outerInset * 2)

        let cardWidth = (availableWidth - spacing * (columns - 1)) / columns
        let cardHeight = (availableHeight - spacing * (rows - 1)) / rows

        let boardWidth = cardWidth * columns + spacing * (columns - 1)
        let boardHeight = cardHeight * rows + spacing * (rows - 1)

        let origin = CGPoint(
            x: (size.width - boardWidth) / 2,
            y: (size.height - boardHeight) / 2
        )

        return BoardMetrics(
            boardFrame: CGRect(origin: origin, size: CGSize(width: boardWidth, height: boardHeight)),
            cardSize: CGSize(width: cardWidth, height: cardHeight),
            spacing: spacing
        )
    }

    private static func adaptiveSpacing(for size: CGSize) -> CGFloat {
        let scaled = min(size.width * 0.012, size.height * 0.024)
        return min(
            GameTuning.maximumGridSpacing,
            max(GameTuning.minimumGridSpacing, max(GameTuning.preferredGridSpacing, scaled))
        )
    }
}
