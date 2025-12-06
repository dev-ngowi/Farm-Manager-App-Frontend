import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Note: You will need to import the AuthBloc and use BlocListener here
// to navigate away after the form is submitted and the UserEntity.hasCompletedDetails 
// flag is updated (e.g., via a new Bloc event like UserDetailsSubmitted).

class RoleDetailsFormPage extends StatelessWidget {
  static const String routeName = '/role-details';
  const RoleDetailsFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine the user's role here to customize the form title
    // Example: final role = context.select((AuthBloc bloc) => bloc.state.user?.role);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile Details'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.description, size: 80, color: Colors.blueGrey),
              const SizedBox(height: 20),
              // Use the actual role here
              Text(
                'Welcome! Please fill in the details required for your role.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 40),
              // ⭐ Placeholder for the role-specific form ⭐
              const Text(
                '--- [Role Specific Form Goes Here] ---',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              // e.g., for Farmer: Farm Name, Size, Type
              // e.g., for Vet: License Number, Specialty
              // e.g., for Researcher: Institution, Research Focus
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement form submission logic and update AuthBloc with a new UserEntity
                  // with hasCompletedDetails: true.
                  // After success, context.go(expectedDashboard) or context.go(LocationManagerPage.routeName) 
                  // depending on which step comes next.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Submitting details (TODO: Implement logic)'))
                  );
                  
                  // For now, let's pretend it worked and go to dashboard (which will be redirected by GoRouter)
                  context.go('/farmer/dashboard'); // Use any configured route to trigger GoRouter check
                },
                child: const Text('Save and Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}