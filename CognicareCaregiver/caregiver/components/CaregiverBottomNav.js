import React from "react";
import { Text, TouchableOpacity, View } from "react-native";

const items = [
  { id: "home", icon: "⌂", label: "Home" },
  { id: "activity", icon: "◫", label: "Activities" },
  { id: "report", icon: "▥", label: "Report" },
  { id: "alerts", icon: "!", label: "Alerts" },
  { id: "patient", icon: "○", label: "Patient" },
];

export default function CaregiverBottomNav({ current, onNavigate }) {
  return (
    <View
      style={{
        height: 72,
        backgroundColor: "#FFFFFF",
        borderTopWidth: 1,
        borderTopColor: "#DDE4DF",
        flexDirection: "row",
        justifyContent: "space-around",
        alignItems: "center",
      }}
    >
      {items.map((item) => {
        const active = current === item.id;

        return (
          <TouchableOpacity
            key={item.id}
            onPress={() => onNavigate(item.id)}
            style={{ alignItems: "center", width: 70 }}
          >
            <Text
              style={{
                fontSize: 21,
                color: active ? "#31584C" : "#8A9793",
                fontWeight: active ? "800" : "500",
              }}
            >
              {item.icon}
            </Text>
            <Text
              style={{
                fontSize: 9,
                marginTop: 3,
                color: active ? "#31584C" : "#8A9793",
                fontWeight: active ? "800" : "600",
              }}
            >
              {item.label}
            </Text>
          </TouchableOpacity>
        );
      })}
    </View>
  );
}
