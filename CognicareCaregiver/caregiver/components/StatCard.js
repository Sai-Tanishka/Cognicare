import React from "react";
import { Text, View } from "react-native";

export default function StatCard({ icon, value, label, danger }) {
  return (
    <View
      style={{
        width: "48%",
        backgroundColor: "#FFFFFF",
        borderRadius: 18,
        padding: 14,
        marginBottom: 10,
        borderWidth: 1,
        borderColor: "#DDE4DF",
      }}
    >
      <View
        style={{
          width: 34,
          height: 34,
          borderRadius: 11,
          backgroundColor: danger ? "#FBE8E6" : "#E4EEE8",
          alignItems: "center",
          justifyContent: "center",
          marginBottom: 8,
        }}
      >
        <Text
          style={{
            color: danger ? "#D96B68" : "#31584C",
            fontWeight: "900",
          }}
        >
          {icon}
        </Text>
      </View>

      <Text style={{ fontSize: 21, fontWeight: "900", color: "#17352F" }}>
        {value}
      </Text>

      <Text style={{ fontSize: 9, color: "#6E7D79", marginTop: 3 }}>
        {label}
      </Text>
    </View>
  );
}
