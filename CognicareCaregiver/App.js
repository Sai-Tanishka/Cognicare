import React, { useEffect, useState } from "react";
import { SafeAreaView, StatusBar, Text, TouchableOpacity, View } from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";

import CaregiverLoginScreen from "./caregiver/screens/CaregiverLoginScreen";
import PatientSelectionScreen from "./caregiver/screens/PatientSelectionScreen";
import CaregiverDashboard from "./caregiver/screens/CaregiverDashboard";
import ActivitiesScreen from "./caregiver/screens/ActivitiesScreen";
import ReportScreen from "./caregiver/screens/ReportScreen";
import AlertsScreen from "./caregiver/screens/AlertsScreen";
import PatientProfileScreen from "./caregiver/screens/PatientProfileScreen";
import CaregiverBottomNav from "./caregiver/components/CaregiverBottomNav";
import {
  attachPatient,
  caregiverLogin,
  caregiverRegister,
  getCaregiverPatients,
  registerPatient as registerPatientApi,
} from "./caregiver/data/api";

const CAREGIVER_SESSION_KEY = "caregiver_logged_in";

function RoleSelectionScreen({ onCaregiver }) {
  const openPatientApp = () => {
    if (typeof window !== "undefined") {
      window.location.assign("http://localhost:5000");
    }
  };

  return (
    <SafeAreaView style={roleStyles.screen}>
      <View style={roleStyles.content}>
        <View style={roleStyles.logo}>
          <Text style={roleStyles.logoText}>🧠</Text>
        </View>
        <Text style={roleStyles.title}>Welcome to Cognicare</Text>
        <Text style={roleStyles.subtitle}>Choose how you want to continue.</Text>

        <TouchableOpacity style={roleStyles.card} onPress={openPatientApp}>
          <Text style={roleStyles.cardTitle}>Patient Login</Text>
          <Text style={roleStyles.cardSubtitle}>Access activities and progress</Text>
        </TouchableOpacity>

        <TouchableOpacity style={roleStyles.card} onPress={onCaregiver}>
          <Text style={roleStyles.cardTitle}>Caregiver Login</Text>
          <Text style={roleStyles.cardSubtitle}>Manage patient care and reports</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

export default function App() {
  const [screen, setScreen] = useState("home");
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [roleSelected, setRoleSelected] = useState(false);
  const [selectedPatient, setSelectedPatient] = useState(null);
  const [attachedPatients, setAttachedPatients] = useState([]);

  useEffect(() => {
    AsyncStorage.removeItem("caregiver_selected_patient").then(() => {
      setIsLoggedIn(false);
      setSelectedPatient(null);
      setAttachedPatients([]);
      setIsLoading(false);
    });
  }, []);

  const login = async (email, password) => {
    const result = await caregiverLogin(email, password);
    const caregiver = result.person;
    const databasePatients = await getCaregiverPatients(caregiver.id);
    await AsyncStorage.setItem(CAREGIVER_SESSION_KEY, "true");
    await AsyncStorage.setItem("caregiver_account", JSON.stringify(caregiver));
    await AsyncStorage.setItem("caregiver_patients", JSON.stringify(databasePatients));
    setIsLoggedIn(true);
    setAttachedPatients(databasePatients);
    await syncPendingPatients(caregiver.id, databasePatients);
  };

  const register = async (data) => {
    await caregiverRegister(data);
    await login(data.email, data.password);
  };

  const syncPendingPatients = async (caregiverId, currentPatients) => {
    const pending = JSON.parse(
      (await AsyncStorage.getItem("pending_patient_registrations")) || "[]"
    );
    if (pending.length === 0) {
      return currentPatients;
    }

    const remaining = [];
    const syncedPatients = [...currentPatients];
    for (const item of pending) {
      try {
        const created = await registerPatientApi(item.patient);
        const attached = await attachPatient(caregiverId, created.id);
        syncedPatients.push({
          ...attached,
          age: item.patient.age,
          gender: item.patient.gender,
          caregiverName: "Current caregiver",
          syncStatus: "Synced",
        });
      } catch (_) {
        remaining.push(item);
      }
    }

    await AsyncStorage.setItem(
      "pending_patient_registrations",
      JSON.stringify(remaining)
    );
    await AsyncStorage.setItem("caregiver_patients", JSON.stringify(syncedPatients));
    setAttachedPatients(syncedPatients);
    return syncedPatients;
  };

  useEffect(() => {
    if (!isLoggedIn) {
      return;
    }

    Promise.all([
      AsyncStorage.getItem("caregiver_account"),
      AsyncStorage.getItem("caregiver_patients"),
    ]).then(([storedAccount, storedPatients]) => {
      if (storedAccount) {
        syncPendingPatients(
          JSON.parse(storedAccount).id,
          storedPatients ? JSON.parse(storedPatients) : []
        );
      }
    });
  }, [isLoggedIn]);

  const logout = async () => {
    await AsyncStorage.removeItem(CAREGIVER_SESSION_KEY);
    await AsyncStorage.removeItem("caregiver_selected_patient");
    setIsLoggedIn(false);
    setSelectedPatient(null);
    setScreen("home");
  };

  const selectPatient = async (patient) => {
    await AsyncStorage.setItem("caregiver_selected_patient", JSON.stringify(patient));
    setSelectedPatient(patient);
  };

  const registerPatient = async (patient) => {
    const caregiver = JSON.parse(await AsyncStorage.getItem("caregiver_account"));
    let attachedPatient;

    try {
      const createdPatient = await registerPatientApi(patient);
      attachedPatient = await attachPatient(caregiver.id, createdPatient.id);
    } catch (error) {
      const pendingPatients = JSON.parse(
        (await AsyncStorage.getItem("pending_patient_registrations")) || "[]"
      );
      const localPatient = {
        ...patient,
        id: `offline-${Date.now()}`,
        caregiverName: caregiver.name,
        syncStatus: "Pending upload",
      };
      await AsyncStorage.setItem(
        "pending_patient_registrations",
        JSON.stringify([...pendingPatients, { patient, caregiverId: caregiver.id }])
      );
      attachedPatient = localPatient;
    }

    const nextPatients = [
      ...attachedPatients,
      { ...attachedPatient, age: patient.age, gender: patient.gender, caregiverName: caregiver.name },
    ];
    await AsyncStorage.setItem("caregiver_patients", JSON.stringify(nextPatients));
    setAttachedPatients(nextPatients);
    await selectPatient({
      ...attachedPatient,
      age: patient.age,
      gender: patient.gender,
      caregiverName: caregiver.name,
    });
  };

  if (isLoading) {
    return <SafeAreaView style={{ flex: 1, backgroundColor: "#F7F8F3" }} />;
  }

  if (!isLoggedIn) {
    if (!roleSelected) {
      return <RoleSelectionScreen onCaregiver={() => setRoleSelected(true)} />;
    }
    return <CaregiverLoginScreen onLogin={login} onRegister={register} />;
  }

  if (!selectedPatient) {
    return (
      <PatientSelectionScreen
        patientOptions={attachedPatients}
        onSelect={selectPatient}
        onRegister={registerPatient}
      />
    );
  }

  const renderScreen = () => {
    switch (screen) {
      case "activity":
        return <ActivitiesScreen onNavigate={setScreen} />;
      case "report":
        return <ReportScreen onNavigate={setScreen} />;
      case "alerts":
        return <AlertsScreen onNavigate={setScreen} />;
      case "patient":
        return <PatientProfileScreen onNavigate={setScreen} onLogout={logout} selectedPatient={selectedPatient} />;
      default:
        return <CaregiverDashboard onNavigate={setScreen} selectedPatient={selectedPatient} />;
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

const roleStyles = {
  screen: { flex: 1, backgroundColor: "#F7F8F3" },
  content: { flex: 1, justifyContent: "center", padding: 28 },
  logo: { width: 74, height: 74, borderRadius: 20, backgroundColor: "#376B5C", alignItems: "center", justifyContent: "center", alignSelf: "center", marginBottom: 24 },
  logoText: { fontSize: 38 },
  title: { color: "#17352F", fontSize: 28, fontWeight: "900", textAlign: "center" },
  subtitle: { color: "#6E7D79", fontSize: 15, textAlign: "center", marginTop: 8, marginBottom: 28 },
  card: { backgroundColor: "#FFFFFF", borderWidth: 1, borderColor: "#D5E1DB", borderRadius: 16, padding: 20, marginTop: 14 },
  cardTitle: { color: "#17352F", fontSize: 18, fontWeight: "900" },
  cardSubtitle: { color: "#6E7D79", fontSize: 13, marginTop: 5 },
};
