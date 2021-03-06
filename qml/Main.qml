/*
 * Copyright (C) 2020  Matthias Dahlmanns
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * einkaufszettel is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import Ubuntu.Components 1.3
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

import "panels"
import "db"

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'einkaufszettel.matdahl'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    // the database connector which manages all DB interactions for entries and categories
    property var dbcon: DBconnector{}

    // the database connector to store the history of entries if wanted
    DBHistory{
        id: db_history
    }

    // the colors object which stores all informations about current color theme settings
    Colors{
        id: colors
        initialIndex: 1
    }

    // set the theme and background color
    theme.name: colors.darkMode ? "Ubuntu.Components.Themes.SuruDark" : "Ubuntu.Components.Themes.Ambiance"

    // the units to measure quantities of entries
    Dimensions{
        id: dimensions
    }



    Page {
        anchors.fill: parent
        header: PageHeader {
            id: header
            //title: i18n.tr("Shopping List")
            StyleHints{backgroundColor: colors.currentHeader}

            leadingActionBar.actions: [
                Action{
                    iconName: "back"
                    visible: stack.depth>1
                    onTriggered: stack.pop()
                }
            ]
            trailingActionBar.actions: [
                Action{
                    iconName: "settings"
                    onTriggered: {
                        while (stack.depth>1 && stack.currentItem!==settingsPanel) stack.pop()
                        if (stack.currentItem!==settingsPanel) {
                            stack.push(settingsPanel)
                        }
                    }
                    visible: stack.currentItem === listPanel
                },
                Action{
                    iconName: "reset"
                    visible: stack.currentItem.headerSuffix === i18n.tr("Units")
                    onTriggered: stack.currentItem.reset()
                },
                Action{
                    iconName: "select"
                    visible: typeof stack.currentItem.checkMode !== "undefined"
                    onTriggered: stack.currentItem.checkMode = !stack.currentItem.checkMode
                },
                Action{
                    iconName: "select-none"
                    visible: stack.currentItem.hasCheckedEntries
                    onTriggered: stack.currentItem.deselectAll()
                }

            ]
        }
        Rectangle{
            anchors.fill: parent
            color: colors.currentBackground
        }
        StackView{
            id: stack
            anchors.fill: parent
            onCurrentItemChanged: header.title = i18n.tr("Shopping List") + ((currentItem.headerSuffix !== "") ? " - "+currentItem.headerSuffix : "")
        }

        ListPanel{
            id: listPanel
            Component.onCompleted: stack.push(listPanel)
            dbcon:    root.dbcon
        }

        SettingsPanel{
            id: settingsPanel
            visible: false
            dbcon:    root.dbcon
            stack:  stack
            colors: colors
            dimensions:  dimensions
        }
    }
}
