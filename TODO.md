1. Ensure provider method providing repo client are private to provider class
2. if user will be created with duplicate name, entry will be there in auth.users but then when trigger will try to insert in profile table, the operation will fail due to unique display name constraint
3. disable users tab for non-admins
4. Error handelling
