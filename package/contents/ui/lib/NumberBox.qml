/*
 * Copyright 2021-2026  Tino Lorenz <tilrnz@gmx.net>
 * Copyright 2022  Diego Miguel <hello@diegomiguel.me>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kquickcontrolsaddons as KQuickControlsAddonsComponents
import org.kde.kirigami as Kirigami

Rectangle {
	id: numberBox
	property alias text: numberText.text 
	property bool fontSizeChecked: plasmoid.configuration.fontSizeChecked
	property color fontColor: plasmoid.configuration.fontColorChecked ? 
			plasmoid.configuration.fontColor : Kirigami.Theme.textColor
	property bool showWindowIndicator: true
	property bool isPanelHorizontal:
		plasmoid.location === PlasmaCore.Types.TopEdge ||
		plasmoid.location === PlasmaCore.Types.BottomEdge

	border.width: plasmoid.configuration.displayBorder ? plasmoid.configuration.borderThickness : 0
	radius: height > width ? height * (plasmoid.configuration.borderRadius / 100) : width * (plasmoid.configuration.borderRadius / 100)

	Text {
		id: sizeRefText
		visible: false
		text: numberBox.text
		font {
			family: plasmoid.configuration.fontFamily || Kirigami.Theme.defaultFont.family
			bold: plasmoid.configuration.fontBold
			italic: plasmoid.configuration.fontItalic
			pixelSize: fontSizeChecked ? plasmoid.configuration.fontSize : Kirigami.Theme.defaultFont.pixelSize
		}
	}

	Layout.minimumWidth: isPanelHorizontal ? sizeRefText.width + 15 : sizeRefText
	Layout.minimumHeight: isPanelHorizontal ? sizeRefText.height : sizeRefText.width + 15

	Layout.preferredWidth: isPanelHorizontal && iconGrid.showAllIcons && plasmoid.configuration.showWindowIcons ? iconGrid.iconSize * tasksModel.count + 15 : sizeRefText.width
	Layout.preferredHeight: !isPanelHorizontal && iconGrid.showAllIcons && plasmoid.configuration.showWindowIcons ? iconGrid.iconSize * tasksModel.count + 15 : sizeRefText.height

	Layout.fillWidth: Plasmoid.formFactor != PlasmaCore.Types.Horizontal
	Layout.fillHeight: Plasmoid.formFactor != PlasmaCore.Types.Vertical

	Rectangle {
		id: windowIndicator
		visible: numberBox.showWindowIndicator

		anchors.left: numberText.right
		anchors.top: numberText.top

		width: 8
		height: 8
		border.color: numberBox.fontColor
		border.width: 1
		color: "transparent"
		radius: width * (plasmoid.configuration.windowIndicatorRadius / 100)
	}

	Text {
		id: numberText
		visible: !plasmoid.configuration.showWindowIcons || tasksModel.count === 0

		anchors.centerIn: parent
		width: parent.width
		height: parent.height
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter

		color: fontColor
		font {
			family: plasmoid.configuration.fontFamily || Kirigami.Theme.defaultFont.family
			bold: plasmoid.configuration.fontBold
			italic: plasmoid.configuration.fontItalic
			pixelSize: fontSizeChecked ? plasmoid.configuration.fontSize : 999
		}
		fontSizeMode: fontSizeChecked ? Text.FixedSize : Text.Fit
		minimumPixelSize: Kirigami.Theme.smallFont.pixelSize
	}

	Grid {
		id: iconGrid
		anchors.centerIn: parent
		visible: plasmoid.configuration.showWindowIcons && tasksModel.count > 0
		spacing: 2

		readonly property bool showIconsInColumn: !isPanelHorizontal
		readonly property bool showAllIcons: tasksModel.count <= plasmoid.configuration.iconsPerDesktop
		readonly property int shorterSide: Math.min(numberBox.height, numberBox.width)
		readonly property int iconSize: shorterSide * 0.85
		

		columns: (showIconsInColumn || !showAllIcons) ? 1 : tasksModel.count
		rows: (showIconsInColumn && showAllIcons) ? tasksModel.count : 1
		flow: showIconsInColumn ? Grid.TopToBottom : Grid.LeftToRight

		component BoxIcon: Kirigami.Icon {
			height: iconGrid.iconSize
			width: iconGrid.iconSize
			roundToIconSize: false
		}

		Repeater {
			model: tasksModel
			BoxIcon {
				visible: iconGrid.showAllIcons
				source: model.decoration
			}
		}

		Kirigami.Icon {
			height: iconGrid.shorterSide * 0.9
			width: iconGrid.shorterSide * 0.9
			roundToIconSize: false
			visible: !iconGrid.showAllIcons
			source: iconGrid.showIconsInColumn ? "view-more-symbolic" : "view-more-horizontal-symbolic"
		}
	}

}
