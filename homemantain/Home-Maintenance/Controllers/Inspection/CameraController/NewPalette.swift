import UIKit
import NXDrawKit

open class NewPalette: UIView {
    @objc open weak var delegate: PaletteDelegate?
    private let brush = Brush()
    private let brushWidthPreferenceKey = "InspectionPhotoBrushWidthIndex"
    private let colors: [UIColor] = [
        UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1),
        UIColor.green,
        UIColor(red: 0.2, green: 0.3, blue: 1, alpha: 1)
    ]
    private var colorButtons: [UIButton] = []
    private var widthButtons: [UIButton] = []
    private var widthDots: [UIView] = []
    private var alphaButtons: [UIButton] = []
    private let opacities: [CGFloat] = [1.0 / 3.0, 2.0 / 3.0, 1]
    private var selectedAlpha = 2
    private let row = UIStackView()
    private var selectedColor = 0
    private var selectedWidth = 0

    public init() {
        super.init(frame: .zero)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc open func currentBrush() -> Brush { return brush }
    @objc open func paletteHeight() -> CGFloat { return 64 }

    override open var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: paletteHeight())
    }

    @objc open func setup() {
        guard colorButtons.isEmpty else { return }
        backgroundColor = UIColor(red: 0.22, green: 0.22, blue: 0.21, alpha: 1)
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(content)
        content.addSubview(row)
        let preferredWidth = content.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        preferredWidth.priority = .defaultHigh
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: paletteHeight()),
            content.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            content.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
            content.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.widthAnchor),
            content.widthAnchor.constraint(greaterThanOrEqualTo: row.widthAnchor, constant: 24),
            preferredWidth,
            row.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            row.topAnchor.constraint(equalTo: content.topAnchor, constant: 10)
        ])

        for (index, color) in colors.enumerated() {
            let button = makeButton(index: index)
            button.backgroundColor = color
            button.layer.cornerRadius = 22
            button.accessibilityLabel = ["紅色", "綠色", "藍色"][index]
            button.addTarget(self, action: #selector(selectColor(_:)), for: .touchUpInside)
            colorButtons.append(button)
            row.addArrangedSubview(button)
        }

        let separator = UIView()
        separator.backgroundColor = UIColor.gray
        separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 32).isActive = true
        row.addArrangedSubview(separator)

        for index in 0..<3 {
            let button = makeButton(index: index)
            button.layer.cornerRadius = 8
            button.accessibilityLabel = ["最細筆觸", "較細筆觸", "中等筆觸"][index]
            button.addTarget(self, action: #selector(selectWidth(_:)), for: .touchUpInside)
            let dot = UIView()
            // Preview dots fit inside a 44-point tap target; drawing widths stay unchanged.
            let diameter: CGFloat = [10, 16, 22][index]
            dot.frame = CGRect(x: (44 - diameter) / 2, y: (44 - diameter) / 2,
                               width: diameter, height: diameter)
            dot.layer.cornerRadius = diameter / 2
            dot.isUserInteractionEnabled = false
            button.addSubview(dot)
            widthDots.append(dot)
            widthButtons.append(button)
            row.addArrangedSubview(button)
        }

        let alphaSeparator = UIView()
        alphaSeparator.backgroundColor = UIColor.gray
        alphaSeparator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        alphaSeparator.heightAnchor.constraint(equalToConstant: 32).isActive = true
        row.addArrangedSubview(alphaSeparator)
        for index in opacities.indices {
            let button = makeButton(index: index)
            button.layer.cornerRadius = 22
            button.accessibilityLabel = "不透明度 \(Int((opacities[index] * 100).rounded()))%"
            button.addTarget(self, action: #selector(selectAlpha(_:)), for: .touchUpInside)
            alphaButtons.append(button)
            row.addArrangedSubview(button)
        }

        let savedIndex = UserDefaults.standard.integer(forKey: brushWidthPreferenceKey)
        selectedWidth = max(0, min(savedIndex, 2))
        brush.alpha = 1
        brush.color = colors[selectedColor]
        brush.width = brushWidth(selectedWidth)
        refreshSelection()
    }

    private func makeButton(index: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.tag = index
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.borderWidth = 2
        return button
    }

    private func brushWidth(_ index: Int) -> CGFloat {
        // Preserve the three smallest widths from the original palette.
        let base = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 10
        let widthRatios: [CGFloat] = [0.25, 0.40, 0.55]
        let defaultWidth = base * widthRatios[index]
        if let width = delegate?.widthWithTag?(index + 1), width >= 0, width <= base {
            return width
        }
        return defaultWidth
    }

    @objc private func selectColor(_ button: UIButton) {
        selectedColor = button.tag
        brush.color = colors[selectedColor]
        refreshSelection()
        delegate?.didChangeBrushColor?(brush.color)
    }

    @objc private func selectWidth(_ button: UIButton) {
        selectedWidth = button.tag
        brush.width = brushWidth(selectedWidth)
        UserDefaults.standard.set(selectedWidth, forKey: brushWidthPreferenceKey)
        refreshSelection()
        delegate?.didChangeBrushWidth?(brush.width)
    }

    @objc private func selectAlpha(_ button: UIButton) {
        selectedAlpha = button.tag
        brush.alpha = opacities[selectedAlpha]
        refreshSelection()
        delegate?.didChangeBrushAlpha?(brush.alpha)
    }

    private func refreshSelection() {
        for (index, button) in colorButtons.enumerated() {
            button.isSelected = index == selectedColor
            button.layer.borderColor = (button.isSelected ? UIColor.white : UIColor.clear).cgColor
        }
        for (index, button) in alphaButtons.enumerated() {
            button.isSelected = index == selectedAlpha
            button.layer.borderColor = (button.isSelected ? UIColor.white : UIColor.clear).cgColor
            button.backgroundColor = brush.color.withAlphaComponent(opacities[index])
        }
        for (index, button) in widthButtons.enumerated() {
            button.isSelected = index == selectedWidth
            button.layer.borderColor = (button.isSelected ? UIColor.white : UIColor.clear).cgColor
            widthDots[index].backgroundColor = brush.color.withAlphaComponent(brush.alpha)
        }
    }
}
