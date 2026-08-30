"""Initial database schema

Revision ID: 001
Revises: 
Create Date: 2026-08-29

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '001'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # Create users table
    op.create_table('users',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('name', sa.String(), nullable=False),
        sa.Column('email', sa.String(), nullable=False),
        sa.Column('password_hash', sa.String(), nullable=False),
        sa.Column('role', sa.Enum('ADMIN', 'TEACHER', name='userrole'), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_users_email'), 'users', ['email'], unique=True)
    op.create_index(op.f('ix_users_id'), 'users', ['id'], unique=False)

    # Create classes table
    op.create_table('classes',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('name', sa.String(), nullable=False),
        sa.Column('grade', sa.String(), nullable=True),
        sa.Column('section', sa.String(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_classes_id'), 'classes', ['id'], unique=False)

    # Create students table
    op.create_table('students',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('student_id', sa.String(), nullable=False),
        sa.Column('first_name', sa.String(), nullable=False),
        sa.Column('middle_name', sa.String(), nullable=True),
        sa.Column('last_name', sa.String(), nullable=False),
        sa.Column('gender', sa.String(), nullable=True),
        sa.Column('date_of_birth', sa.Date(), nullable=True),
        sa.Column('grade', sa.String(), nullable=True),
        sa.Column('section', sa.String(), nullable=True),
        sa.Column('class_id', sa.Integer(), nullable=True),
        sa.Column('guardian_name', sa.String(), nullable=True),
        sa.Column('guardian_phone', sa.String(), nullable=True),
        sa.Column('guardian_email', sa.String(), nullable=True),
        sa.Column('status', sa.Enum('ACTIVE', 'INACTIVE', 'GRADUATED', name='studentstatus'), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(['class_id'], ['classes.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_students_id'), 'students', ['id'], unique=False)
    op.create_index(op.f('ix_students_student_id'), 'students', ['student_id'], unique=True)

    # Create face_embeddings table
    op.create_table('face_embeddings',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('student_id', sa.Integer(), nullable=False),
        sa.Column('embedding', sa.LargeBinary(), nullable=False),
        sa.Column('model_name', sa.String(), nullable=False),
        sa.Column('model_version', sa.String(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(['student_id'], ['students.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_face_embeddings_id'), 'face_embeddings', ['id'], unique=False)

    # Create attendance_sessions table
    op.create_table('attendance_sessions',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('class_id', sa.Integer(), nullable=False),
        sa.Column('teacher_id', sa.Integer(), nullable=False),
        sa.Column('date', sa.Date(), nullable=False),
        sa.Column('status', sa.Enum('OPEN', 'CLOSED', name='sessionstatus'), nullable=True),
        sa.Column('started_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('closed_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(['class_id'], ['classes.id'], ),
        sa.ForeignKeyConstraint(['teacher_id'], ['users.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_attendance_sessions_id'), 'attendance_sessions', ['id'], unique=False)

    # Create attendance table
    op.create_table('attendance',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('session_id', sa.Integer(), nullable=False),
        sa.Column('student_id', sa.Integer(), nullable=False),
        sa.Column('status', sa.Enum('PRESENT', 'ABSENT', name='attendancestatus'), nullable=False),
        sa.Column('method', sa.Enum('FACE', 'QR', 'MANUAL', name='attendancemethod'), nullable=True),
        sa.Column('recognized_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(['session_id'], ['attendance_sessions.id'], ),
        sa.ForeignKeyConstraint(['student_id'], ['students.id'], ),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('session_id', 'student_id', name='unique_session_student_attendance')
    )
    op.create_index(op.f('ix_attendance_id'), 'attendance', ['id'], unique=False)

    # Create notifications table
    op.create_table('notifications',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('student_id', sa.Integer(), nullable=False),
        sa.Column('guardian_name', sa.String(), nullable=False),
        sa.Column('guardian_phone', sa.String(), nullable=False),
        sa.Column('message', sa.String(), nullable=False),
        sa.Column('status', sa.Enum('PENDING', 'SENT', 'FAILED', name='notificationstatus'), nullable=True),
        sa.Column('sent_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(['student_id'], ['students.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_notifications_id'), 'notifications', ['id'], unique=False)

    # Create audit_logs table
    op.create_table('audit_logs',
        sa.Column('id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.Column('action', sa.String(), nullable=False),
        sa.Column('entity_type', sa.String(), nullable=False),
        sa.Column('entity_id', sa.Integer(), nullable=True),
        sa.Column('audit_metadata', sa.JSON(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index(op.f('ix_audit_logs_id'), 'audit_logs', ['id'], unique=False)


def downgrade():
    op.drop_index(op.f('ix_audit_logs_id'), table_name='audit_logs')
    op.drop_table('audit_logs')
    op.drop_index(op.f('ix_notifications_id'), table_name='notifications')
    op.drop_table('notifications')
    op.drop_index(op.f('ix_attendance_id'), table_name='attendance')
    op.drop_table('attendance')
    op.drop_index(op.f('ix_attendance_sessions_id'), table_name='attendance_sessions')
    op.drop_table('attendance_sessions')
    op.drop_index(op.f('ix_face_embeddings_id'), table_name='face_embeddings')
    op.drop_table('face_embeddings')
    op.drop_index(op.f('ix_students_student_id'), table_name='students')
    op.drop_index(op.f('ix_students_id'), table_name='students')
    op.drop_table('students')
    op.drop_index(op.f('ix_classes_id'), table_name='classes')
    op.drop_table('classes')
    op.drop_index(op.f('ix_users_id'), table_name='users')
    op.drop_index(op.f('ix_users_email'), table_name='users')
    op.drop_table('users')