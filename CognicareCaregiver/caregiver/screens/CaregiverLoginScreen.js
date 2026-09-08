import React, { useState } from "react";
import { SafeAreaView, Text, TextInput, TouchableOpacity, View } from "react-native";

export default function CaregiverLoginScreen({ onLogin, onRegister }) {
  const [isRegistering, setIsRegistering] = useState(false);
  const [name, setName] = useState("");
  const [phone, setPhone] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const submit = async () => {
    if (isRegistering && !name.trim()) {
      setError("Enter your name.");
      return;
    }

    if (!email.trim() || !email.includes("@")) {
      setError("Enter a valid caregiver email.");
      return;
    }

    if (password.length < 8) {
      setError("Password must be at least 8 characters.");
      return;
    }

    setError("");
    try {
      if (isRegistering) {
        await onRegister({ name: name.trim(), email: email.trim(), password, phone });
      } else {
        await onLogin(email.trim(), password);
      }
    } catch (requestError) {
      setError(requestError.message || "Unable to connect to the backend.");
    }
  };

  return (
    <SafeAreaView style={styles.screen}>
      <View style={styles.content}>
        <View style={styles.logo}>
          <Text style={styles.logoText}>🧠</Text>
        </View>
        <Text style={styles.title}>{isRegistering ? "Create Caregiver Account" : "Caregiver Login"}</Text>
        <Text style={styles.subtitle}>{isRegistering ? "Register once to manage patient care." : "Sign in to manage patient care."}</Text>

        {isRegistering ? (
          <>
            <Text style={styles.label}>Name</Text>
            <TextInput value={name} onChangeText={setName} placeholder="Your full name" placeholderTextColor="#8A9691" style={styles.input} />
            <Text style={styles.label}>Phone</Text>
            <TextInput value={phone} onChangeText={setPhone} keyboardType="phone-pad" placeholder="Phone number" placeholderTextColor="#8A9691" style={styles.input} />
          </>
        ) : null}

        <Text style={styles.label}>Email</Text>
        <TextInput
          value={email}
          onChangeText={setEmail}
          autoCapitalize="none"
          keyboardType="email-address"
          placeholder="caregiver@example.com"
          placeholderTextColor="#8A9691"
          style={styles.input}
        />

        <Text style={styles.label}>Password</Text>
        <TextInput
          value={password}
          onChangeText={setPassword}
          secureTextEntry
          placeholder="Enter your password"
          placeholderTextColor="#8A9691"
          style={styles.input}
        />

        {error ? <Text style={styles.error}>{error}</Text> : null}

        <TouchableOpacity style={styles.button} onPress={submit}>
          <Text style={styles.buttonText}>{isRegistering ? "Register" : "Log In"}</Text>
        </TouchableOpacity>
        <TouchableOpacity onPress={() => { setIsRegistering(!isRegistering); setError(""); }}>
          <Text style={styles.switchText}>{isRegistering ? "Already registered? Log in" : "New caregiver? Create an account"}</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

const styles = {
  screen: { flex: 1, backgroundColor: "#F7F8F3" },
  content: { flex: 1, justifyContent: "center", padding: 28 },
  logo: { width: 74, height: 74, borderRadius: 20, backgroundColor: "#376B5C", alignItems: "center", justifyContent: "center", alignSelf: "center", marginBottom: 22 },
  logoText: { color: "#FFFFFF", fontSize: 38, fontWeight: "900" },
  title: { color: "#17352F", fontSize: 28, fontWeight: "900", textAlign: "center" },
  subtitle: { color: "#6E7D79", fontSize: 14, textAlign: "center", marginTop: 7, marginBottom: 34 },
  label: { color: "#17352F", fontSize: 14, fontWeight: "800", marginBottom: 8, marginTop: 14 },
  input: { backgroundColor: "#FFFFFF", borderWidth: 1, borderColor: "#D5E1DB", borderRadius: 14, paddingHorizontal: 16, paddingVertical: 15, fontSize: 16, color: "#17352F" },
  error: { color: "#B64747", fontSize: 13, marginTop: 12 },
  button: { backgroundColor: "#376B5C", borderRadius: 14, paddingVertical: 16, alignItems: "center", marginTop: 26 },
  buttonText: { color: "#FFFFFF", fontSize: 17, fontWeight: "900" },
  switchText: { color: "#376B5C", fontSize: 14, fontWeight: "800", textAlign: "center", marginTop: 20 },
};
