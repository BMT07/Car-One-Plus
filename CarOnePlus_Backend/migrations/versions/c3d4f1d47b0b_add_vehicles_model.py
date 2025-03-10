"""Add vehicles model

Revision ID: c3d4f1d47b0b
Revises: a921ed3a3a0e
Create Date: 2024-12-18 11:51:03.384127

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'c3d4f1d47b0b'
down_revision = 'a921ed3a3a0e'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('vehicle',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('owner_id', sa.Integer(), nullable=False),
    sa.Column('title', sa.String(length=100), nullable=False),
    sa.Column('description', sa.Text(), nullable=False),
    sa.Column('price_per_day', sa.Float(), nullable=False),
    sa.Column('location', sa.String(length=100), nullable=False),
    sa.Column('available', sa.Boolean(), nullable=True),
    sa.Column('created_at', sa.DateTime(), server_default=sa.text('now()'), nullable=True),
    sa.ForeignKeyConstraint(['owner_id'], ['user.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_table('vehicle')
    # ### end Alembic commands ###
