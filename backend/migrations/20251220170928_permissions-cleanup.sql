-- Convert legacy Visualizer and None permissions to Viewer
UPDATE users SET permissions = 'Viewer' WHERE permissions IN ('Visualizer', 'None');
UPDATE invites SET permissions = 'Viewer' WHERE permissions IN ('Visualizer', 'None');
