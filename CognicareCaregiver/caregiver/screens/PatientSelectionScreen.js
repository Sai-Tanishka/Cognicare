import React, { useState } from "react";
import { ScrollView, Text, TextInput, TouchableOpacity, View } from "react-native";

import { patients } from "../data/patientData";

export default function PatientSelectionScreen({ patientOptions, onSelect, onRegister }) {
  const [showForm, setShowForm] = useState(false);
  const [name, setName] = useState("");
  const [age, setAge] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const registerPatient = () => {
    if (!name.trim() || !age.trim() || !email.includes("@") || password.length < 8) {
      setError("Enter the patient's name, age, valid email, and an 8-character password.");
      return;
    }

    onRegister({
      id: `P-${Date.now()}`,
      name: name.trim(),
      email: email.trim(),
      password,
      age: Number(age),
      gender: "Not specified",
      preferredLanguage: "English",
      caregiverName: "Current caregiver",
      careMode: "Gaming + Voice Assistance",
      lastActive: "Not yet active",
    });
  };

  return (
    <View style={styles.screen}>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.title}>Choose a Patient</Text>
        <Text style={styles.subtitle}>
          Select a patient to open their care dashboard.
        </Text>

        {(patientOptions || patients).map((item) => (
          <TouchableOpacity key={item.id} style={styles.patientCard} onPress={() => onSelect(item)}>
            <View style={styles.avatar}>
              <Text style={styles.avatarText}>{item.name.charAt(0)}</Text>
            </View>
            <View style={styles.patientInfo}>
              <Text style={styles.patientName}>{item.name}</Text>
              <Text style={styles.patientDetails}>{item.age} years • {item.gender}</Text>
              <Text style={styles.patientCaregiver}>Caregiver: {item.caregiverName}</Text>
            </View>
            <Text style={styles.arrow}>›</Text>
          </TouchableOpacity>
        ))}

        <TouchableOpacity style={styles.registerButton} onPress={() => setShowForm(!showForm)}>
          <Text style={styles.registerText}>+ Register New Patient</Text>
        </TouchableOpacity>

        {showForm ? (
          <View style={styles.form}>
            <Text style={styles.formTitle}>New Patient</Text>
            <TextInput value={name} onChangeText={setName} placeholder="Patient name" style={styles.input} />
            <TextInput value={age} onChangeText={setAge} placeholder="Age" keyboardType="number-pad" style={styles.input} />
            <TextInput value={email} onChangeText={setEmail} placeholder="Patient email" keyboardType="email-address" autoCapitalize="none" style={styles.input} />
            <TextInput value={password} onChangeText={setPassword} placeholder="Set patient password (8+ characters)" secureTextEntry style={styles.input} />
            {error ? <Text style={styles.error}>{error}</Text> : null}
            <TouchableOpacity style={styles.confirmButton} onPress={registerPatient}>
              <Text style={styles.confirmText}>Register and Continue</Text>
            </TouchableOpacity>
          </View>
        ) : null}
      </ScrollView>
    </View>
  );
}

const styles = {
  screen: { flex: 1, backgroundColor: "#F7F8F3" },
  content: { padding: 22, paddingTop: 70 },
  title: { fontSize: 28, fontWeight: "900", color: "#17352F" },
  subtitle: { fontSize: 14, color: "#6E7D79", lineHeight: 20, marginTop: 7, marginBottom: 24 },
  patientCard: { flexDirection: "row", alignItems: "center", backgroundColor: "#FFFFFF", borderWidth: 1, borderColor: "#DDE4DF", borderRadius: 18, padding: 16, marginBottom: 12 },
  avatar: { width: 54, height: 54, borderRadius: 27, backgroundColor: "#E4EEE8", alignItems: "center", justifyContent: "center", marginRight: 14 },
  avatarText: { fontSize: 24, fontWeight: "900", color: "#31584C" },
  patientInfo: { flex: 1 },
  patientName: { fontSize: 17, fontWeight: "900", color: "#17352F" },
  patientDetails: { fontSize: 12, color: "#6E7D79", marginTop: 3 },
  patientCaregiver: { fontSize: 12, color: "#31584C", marginTop: 4 },
  arrow: { fontSize: 28, color: "#376B5C" },
  registerButton: { borderWidth: 1, borderColor: "#376B5C", borderRadius: 14, paddingVertical: 15, alignItems: "center", marginTop: 8 },
  registerText: { color: "#376B5C", fontSize: 15, fontWeight: "900" },
  form: { backgroundColor: "#FFFFFF", borderRadius: 18, padding: 16, marginTop: 14, borderWidth: 1, borderColor: "#DDE4DF" },
  formTitle: { color: "#17352F", fontSize: 18, fontWeight: "900", marginBottom: 10 },
  input: { borderWidth: 1, borderColor: "#D5E1DB", borderRadius: 12, padding: 13, marginTop: 9, fontSize: 15 },
  error: { color: "#B64747", marginTop: 8 },
  confirmButton: { backgroundColor: "#376B5C", borderRadius: 12, paddingVertical: 14, alignItems: "center", marginTop: 14 },
  confirmText: { color: "#FFFFFF", fontWeight: "900" },
};