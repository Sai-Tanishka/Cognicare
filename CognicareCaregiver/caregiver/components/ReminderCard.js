import React from "react";
import { Text, View } from "react-native";

export default function ReminderCard({ item }) {
  const statusColor =
    item.status === "Taken" || item.status === "Completed"
      ? "#4E987B"
      : item.status === "Missed"
      ? "#D96B68"
      : "#D9A646";

  return (
    <View
      style={{
        backgroundColor: "#FFFFFF",
        borderRadius: 15,
        padding: 13,
        marginBottom: 8,
        flexDirection: "row",
        alignItems: "center",
        borderWidth: 1,
        borderColor: "#DDE4DF",
      }}
    >
      <View
        style={{
          width: 9,
          height: 9,
          borderRadius: 5,
          backgroundColor: statusColor,
          marginRight: 10,
        }}
      />

      <View style={{ flex: 1 }}>
        <Text style={{ fontSize: 11, color: "#17352F", fontWeight: "800" }}>
          {item.title}
        </Text>
        <Text style={{ fontSize: 8, color: "#6E7D79", marginTop: 3 }}>
          {item.time} • {item.type}
        </Text>
      </View>

      <Text style={{ fontSize: 9, color: statusColor, fontWeight: "900" }}>
        {item.status}
      </Text>
    </View>
  );
}
