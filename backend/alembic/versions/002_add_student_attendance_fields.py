"""Add student fields used by QR and critical-attendance features.

Revision ID: 002
Revises: 001
"""
from alembic import op
import sqlalchemy as sa


revision = "002"
down_revision = "001"
branch_labels = None
depends_on = None


def upgrade():
    op.add_column("students", sa.Column("qr_token", sa.String(255), nullable=True))
    op.create_unique_constraint("uq_students_qr_token", "students", ["qr_token"])
    op.add_column("students", sa.Column("critical_attendance", sa.String(50), nullable=True))
    op.add_column("students", sa.Column("is_critical", sa.Boolean(), nullable=True, server_default=sa.false()))


def downgrade():
    op.drop_column("students", "is_critical")
    op.drop_column("students", "critical_attendance")
    op.drop_constraint("uq_students_qr_token", "students", type_="unique")
    op.drop_column("students", "qr_token")