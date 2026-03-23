//
//  AboutAppView.swift
//  Planner
//
//  Created by Saurabh Dhingra on 23/03/26.
//

import SwiftUI

struct AboutAppView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // App Icon and Name
                    appHeaderSection

                    // Developer Section
                    developerSection

                    // Social Links
                    socialLinksSection

                    // App Info
                    appInfoSection

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("About")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - App Header Section
    private var appHeaderSection: some View {
        VStack(spacing: 16) {
            // App Icon
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "note.text")
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                )
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)

            VStack(spacing: 4) {
                Text("Planner")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Your personal note-taking companion")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 20)
    }

    // MARK: - Developer Section
    private var developerSection: some View {
        VStack(spacing: 16) {
            // Profile Image Placeholder
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.orange, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Text("SD")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )

            VStack(spacing: 6) {
                Text("Saurabh Dhingra")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Indie iOS Developer")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                    Text("India")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
        )
    }

    // MARK: - Social Links Section
    private var socialLinksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Connect")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                SocialLinkRow(
                    icon: "link",
                    iconColor: .blue,
                    title: "GitHub",
                    subtitle: "@saurabhdhingra",
                    action: { openURL(URL(string: "https://github.com/saurabhdhingra")!) }
                )

                Divider().padding(.leading, 56)

                SocialLinkRow(
                    icon: "link",
                    iconColor: .blue,
                    title: "LinkedIn",
                    subtitle: "Saurabh Dhingra",
                    action: { openURL(URL(string: "https://linkedin.com/in/saurabhdhingra")!) }
                )

                Divider().padding(.leading, 56)

                SocialLinkRow(
                    icon: "link",
                    iconColor: .pink,
                    title: "Instagram",
                    subtitle: "@saurabhdhingra",
                    action: { openURL(URL(string: "https://instagram.com/saurabhdhingra")!) }
                )

                Divider().padding(.leading, 56)

                SocialLinkRow(
                    icon: "link",
                    iconColor: .cyan,
                    title: "Twitter / X",
                    subtitle: "@saurabhdhingra",
                    action: { openURL(URL(string: "https://twitter.com/saurabhdhingra")!) }
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
        }
    }

    // MARK: - App Info Section
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("App Info")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                InfoRow(title: "Version", value: "1.0.0")
                Divider().padding(.leading, 16)
                InfoRow(title: "Build", value: "1")
                Divider().padding(.leading, 16)
                InfoRow(title: "Platform", value: "iOS 15.0+")
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
        }
    }
}

// MARK: - Social Link Row
struct SocialLinkRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .font(.body)
                            .foregroundColor(iconColor)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)

            Spacer()

            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Preview
#Preview {
    AboutAppView()
}
