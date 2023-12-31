//
//  FlipView.swift
//  iOS Trivia
//
//  Created by Omar Albeik on 8/1/18.
//  Copyright © 2018 Omar Albeik. All rights reserved.
//

import UIKit

protocol FlipViewDelegate: AnyObject {
	func flipView(_ view: FlipView, willFlipToFace face: FlipView.Face)
	func flipView(_ view: FlipView, didFlipToFace face: FlipView.Face)
	func flipView(_ view: FlipView, didSelectAnswerAtIndex index: Int)
}

extension FlipViewDelegate {
	func flipView(_ view: FlipView, willFlipToFace face: FlipView.Face) {}
	func flipView(_ view: FlipView, didFlipToFace face: FlipView.Face) {}
	func flipView(_ view: FlipView, didSelectAnswerAtIndex index: Int) {}
}

final class FlipView: LayoutableView {

	enum Face {
		case front
		case back
	}

	var currentFace: Face = .front

	weak var delegate: FlipViewDelegate?

	lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .center
		label.numberOfLines = 0
		label.font = .systemFont(ofSize: 18, weight: .regular)
		return label
	}()

	lazy var confirmButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle(L10n.Game.Answer.select, for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
		button.tintColor = Color.white
		button.backgroundColor = Color.clear
		button.isHidden = true
		button.addTarget(self, action: #selector(didTapSelectButton), for: .touchUpInside)
		return button
	}()

	override func setupViews() {
		backgroundColor = Color.lightGray

		layer.cornerRadius = 8
		addSubview(titleLabel)
		addSubview(confirmButton)

		let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
		addGestureRecognizer(tap)
	}

	override func setupLayout() {
		titleLabel.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		confirmButton.snp.makeConstraints { make in
			make.top.bottom.equalToSuperview()
			make.height.greaterThanOrEqualTo(preferredPadding * 2.5)
			make.leading.trailing.equalToSuperview().inset(preferredPadding * 2)
		}
	}

}

// MARK: - Helpers
extension FlipView {

	func flip(to face: Face) {
		guard  currentFace != face else { return }

		delegate?.flipView(self, willFlipToFace: face)
		self.currentFace = face
		isUserInteractionEnabled = false

		let options: UIViewAnimationOptions = (face == .front) ? .transitionFlipFromBottom : .transitionFlipFromTop
		UIView.transition(with: self, duration: 0.5, options: options, animations: { [weak self] in
			guard let strongSelf = self else { return }

			strongSelf.titleLabel.isHidden = (face == .back)
			strongSelf.confirmButton.isHidden = (face == .front)
			strongSelf.backgroundColor = (face == .front) ? Color.lightGray : Color.lightYellow
			}, completion: { [weak self] _ in
				guard let strongSelf = self else { return }
				strongSelf.isUserInteractionEnabled = true
				strongSelf.delegate?.flipView(strongSelf, didFlipToFace: face)
		})
	}

}

// MARK: - Actions
private extension FlipView {

	@objc
	func didTap() {
		switch currentFace {
		case .front:
			flip(to: .back)
		case .back:
			flip(to: .front)
		}
	}

	@objc
	func didTapSelectButton() {
		delegate?.flipView(self, didSelectAnswerAtIndex: tag)
	}

}

// MARK: - Configure
extension FlipView {

	func configure(for answer: Answer, index: Int) {
		titleLabel.text = String(htmlEncodedString: answer.text)
		tag = index
	}

}
