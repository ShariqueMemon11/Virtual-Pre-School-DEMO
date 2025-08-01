import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<StatefulWidget> createState() => _SideMenu();
}

class _SideMenu extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Header
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(
                255,
                255,
                255,
                1,
              ), // Moved color inside BoxDecoration
            ),
            child: Center(
              child: Text(
                "Menu",
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        // Menu Items
        Expanded(
          flex: 13,
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SidebarItem(
                  icon: Icons.person,
                  label: 'Profile',
                  onTap: () {
                    // Navigator.push(...);
                  },
                ),
                SidebarItem(
                  icon: Icons.settings,
                  label: 'Setting',
                  onTap: () {},
                ),
                SidebarItem(
                  icon: Icons.message,
                  label: 'Messages',
                  onTap: () {},
                ),
                SidebarItem(
                  icon: Icons.attach_money,
                  label: 'Finances',
                  hasArrow: true,
                  onTap: () {},
                ),
                Expanded(flex: 1, child: Container()),
                SidebarItem(
                  icon: Icons.logout,
                  label: 'LogOut',
                  onTap: () async {
                    // Example if you're using Firebase:
                    // await FirebaseAuth.instance.signOut();
                    await FirebaseAuth.instance.signOut();
                    // After logout, navigate to login screen and clear stack
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool hasArrow;
  final VoidCallback? onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    this.hasArrow = false,
    this.onTap,
  });

  @override
  _SidebarItemState createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        splashColor: Colors.purple.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 200),
          opacity: _isHovered ? 0.5 : 1.0, // Change opacity on hover
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 22.0,
              horizontal: 16.0,
            ),
            child: Row(
              children: [
                Icon(widget.icon, size: 20, color: Colors.blueGrey),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                if (widget.hasArrow)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.blueGrey,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
