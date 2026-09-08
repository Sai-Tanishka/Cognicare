import React, { useState } from "react";
import { SafeAreaView, StatusBar } from "react-native";

import CaregiverDashboard from "./caregiver/screens/CaregiverDashboard";
import ActivitiesScreen from "./caregiver/screens/ActivitiesScreen";
import ReportScreen from "./caregiver/screens/ReportScreen";
import AlertsScreen from "./caregiver/screens/AlertsScreen";
import PatientProfileScreen from "./caregiver/screens/PatientProfileScreen";
import CaregiverBottomNav from "./caregiver/components/CaregiverBottomNav";

export default function App() {
  const [screen, setScreen] = useState("home");

  const renderScreen = () => {
    switch (screen) {
      case "activity":
        return <ActivitiesScreen onNavigate={setScreen} />;
      case "report":
        return <ReportScreen onNavigate={setScreen} />;
      case "alerts":
        return <AlertsScreen onNavigate={setScreen} />;
      case "patient":
        return <PatientProfileScreen onNavigate={setScreen} />;
      default:
        return <CaregiverDashboard onNavigate={setScreen} />;
    }
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: "#F7F8F3" }}>
      <StatusBar barStyle="dark-content" backgroundColor="#F7F8F3" />
      {renderScreen()}
      <CaregiverBottomNav current={screen} onNavigate={setScreen} />
    </SafeAreaView>
  );
}
